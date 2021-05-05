#include <lak/debug.hpp>
#include <lak/endian.hpp>
#include <lak/file.hpp>
#include <lak/memory.hpp>
#include <lak/span.hpp>
#include <lak/unicode.hpp>

#include <iomanip>
#include <iostream>

const auto repl_usage =
  L"repl usage: ctob <utf8|utf16|utf32|utf16le|utf32le|utf16be|utf32be>";
const auto conversion_usage =
  "conversion usage: ctob "
  "[from-file] "
  "[from-encoding <utf8|wide|utf16|utf32|utf16le|utf32le|utf16be|utf32be>] "
  "[to-file] "
  "[to-encoding <utf8|wide|utf16|utf32|utf16le|utf32le|utf16be|utf32be>]";

template<typename FROM_CHAR,
         lak::endian FROM_ENDIAN,
         typename TO_CHAR,
         lak::endian TO_ENDIAN>
int converter(const lak::fs::path &from, const lak::fs::path &to)
{
  if (FROM_ENDIAN != lak::endian::native)
  {
    ASSERT_NYI();
    return EXIT_FAILURE;
  }
  if (TO_ENDIAN != lak::endian::native)
  {
    ASSERT_NYI();
    return EXIT_FAILURE;
  }
  const auto bytes = lak::read_file(from).UNWRAP();

  const auto input = lak::span<const FROM_CHAR>(lak::span(bytes));
  std::vector<uint8_t> output;
  for (const auto &[c, len] : lak::codepoint_range(input))
  {
    DEBUG((size_t)c);
    constexpr size_t buffer_size    = lak::chars_per_codepoint_v<TO_CHAR>;
    TO_CHAR buffer[buffer_size + 1] = {};
    lak::from_codepoint(lak::codepoint_buffer(lak::span(buffer)), c);
    for (const uint8_t v : lak::span<const uint8_t>(
           lak::span(buffer).first(lak::codepoint_length<TO_CHAR>(c))))
    {
      output.push_back(v);
    }
  }
  DEBUG(lak::span(output));
  ASSERT(lak::save_file(to, lak::span(output)));

  return EXIT_SUCCESS;
}

template<typename FROM_CHAR, lak::endian FROM_ENDIAN>
int converter(const lak::fs::path &from,
              const lak::fs::path &to,
              const lak::astring &to_encoding)
{
  if (to_encoding == "ascii")
    return converter<FROM_CHAR, FROM_ENDIAN, char8_t, lak::endian::native>(
      from, to);
  else if (to_encoding == "wide")
    return converter<FROM_CHAR, FROM_ENDIAN, wchar_t, lak::endian::native>(
      from, to);
  else if (to_encoding == "utf8")
    return converter<FROM_CHAR, FROM_ENDIAN, char8_t, lak::endian::native>(
      from, to);
  else if (to_encoding == "utf16")
    return converter<FROM_CHAR, FROM_ENDIAN, char16_t, lak::endian::native>(
      from, to);
  else if (to_encoding == "utf16le")
    return converter<FROM_CHAR, FROM_ENDIAN, char16_t, lak::endian::little>(
      from, to);
  else if (to_encoding == "utf16be")
    return converter<FROM_CHAR, FROM_ENDIAN, char16_t, lak::endian::big>(from,
                                                                         to);
  else if (to_encoding == "utf32")
    return converter<FROM_CHAR, FROM_ENDIAN, char32_t, lak::endian::native>(
      from, to);
  else if (to_encoding == "utf32le")
    return converter<FROM_CHAR, FROM_ENDIAN, char32_t, lak::endian::little>(
      from, to);
  else if (to_encoding == "utf32be")
    return converter<FROM_CHAR, FROM_ENDIAN, char32_t, lak::endian::big>(from,
                                                                         to);

  ASSERT_NYI();
  return EXIT_FAILURE;
}

int converter(const lak::fs::path &from,
              const lak::astring &from_encoding,
              const lak::fs::path &to,
              const lak::astring &to_encoding)
{
  if (from_encoding == "ascii")
    return converter<char8_t, lak::endian::native>(from, to, to_encoding);
  else if (from_encoding == "wide")
    return converter<wchar_t, lak::endian::native>(from, to, to_encoding);
  else if (from_encoding == "utf8")
    return converter<char8_t, lak::endian::native>(from, to, to_encoding);
  else if (from_encoding == "utf16")
    return converter<char16_t, lak::endian::native>(from, to, to_encoding);
  else if (from_encoding == "utf16le")
    return converter<char16_t, lak::endian::little>(from, to, to_encoding);
  else if (from_encoding == "utf16be")
    return converter<char16_t, lak::endian::big>(from, to, to_encoding);
  else if (from_encoding == "utf32")
    return converter<char32_t, lak::endian::native>(from, to, to_encoding);
  else if (from_encoding == "utf32le")
    return converter<char32_t, lak::endian::little>(from, to, to_encoding);
  else if (from_encoding == "utf32be")
    return converter<char32_t, lak::endian::big>(from, to, to_encoding);

  ASSERT_NYI();
  return EXIT_FAILURE;
}

template<typename CHAR, lak::endian ENDIAN>
int repl()
{
  auto print = [](uint32_t c) {
    std::wcout << std::hex << std::uppercase << std::setfill(L'0') << L"\\x"
               << std::setw(2) << c;
  };

  for (uint32_t codepoint;
       std::wcout.good() && (std::cin >> std::hex >> codepoint).good();)
  {
    CHAR buffer[lak::chars_per_codepoint_v<CHAR>];
    auto result = lak::from_codepoint(lak::codepoint_buffer(lak::span(buffer)),
                                      static_cast<char32_t>(codepoint));
    if (ENDIAN == lak::endian::native)
    {
      for (const auto c : result)
      {
        for (const auto v : lak::span<const uint8_t, sizeof(CHAR)>::from_ptr(
               reinterpret_cast<const uint8_t *>(&c)))
        {
          print(v);
        }
      }
    }
    else
    {
      for (const auto c : result)
      {
        auto span = lak::span<const uint8_t, sizeof(CHAR)>::from_ptr(
          reinterpret_cast<const uint8_t *>(&c));
        for (size_t i = sizeof(CHAR); i-- > 0;)
        {
          print(span[i]);
        }
      }
    }
    if (result.size() > 0) std::wcout << L"\n";
  }

  return EXIT_SUCCESS;
}

int repl(const lak::astring &conv_to)
{
  if (conv_to == "utf8")
  {
    return repl<char8_t, lak::endian::native>();
  }
  else if (conv_to == "utf16")
  {
    return repl<char16_t, lak::endian::native>();
  }
  else if (conv_to == "utf16le")
  {
    return repl<char16_t, lak::endian::little>();
  }
  else if (conv_to == "utf16be")
  {
    return repl<char16_t, lak::endian::big>();
  }
  else if (conv_to == "utf32")
  {
    return repl<char32_t, lak::endian::native>();
  }
  else if (conv_to == "utf32le")
  {
    return repl<char32_t, lak::endian::little>();
  }
  else if (conv_to == "utf32be")
  {
    return repl<char32_t, lak::endian::big>();
  }
  else
  {
    std::wcerr << LAK_BRIGHT_RED "unknown encoding '"
               << lak::to_wstring(conv_to) << "'" LAK_SGR_RESET "\n"
               << repl_usage << "\n";
    return EXIT_FAILURE;
  }
}

int main(int argc, const char **argv)
{
  lak::debugger.line_info_enabled = true;

  if (argc == 2)
  {
    return repl(lak::astring(argv[1]));
  }
  else if (argc == 5)
  {
    return converter(lak::fs::path(argv[1]),
                     lak::astring(argv[2]),
                     lak::fs::path(argv[3]),
                     lak::astring(argv[4]));
  }
  else
  {
    std::wcerr << repl_usage << "\n" << conversion_usage << "\n";
    return EXIT_FAILURE;
  }
}
