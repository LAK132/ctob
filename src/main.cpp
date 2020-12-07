#include <lak/debug.hpp>
#include <lak/endian.hpp>
#include <lak/memory.hpp>
#include <lak/span.hpp>
#include <lak/unicode.hpp>

#include <iomanip>
#include <iostream>

template<typename CHAR, lak::endian ENDIAN>
void converter()
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
}

int main(int argc, const char **argv)
{
  lak::debugger.line_info_enabled = false;

  const auto usage =
    L"usage: ctob <utf8|utf16|utf32|utf16le|utf32le|utf16be|utf32be>";

  if (argc != 2)
  {
    std::wcerr << usage << "\n";
    return 1;
  }

  if (const auto conv_to = lak::astring(argv[1]); conv_to == "utf8")
  {
    converter<char8_t, lak::endian::native>();
  }
  else if (conv_to == "utf16")
  {
    converter<char16_t, lak::endian::native>();
  }
  else if (conv_to == "utf16le")
  {
    converter<char16_t, lak::endian::little>();
  }
  else if (conv_to == "utf16be")
  {
    converter<char16_t, lak::endian::big>();
  }
  else if (conv_to == "utf32")
  {
    converter<char32_t, lak::endian::native>();
  }
  else if (conv_to == "utf32le")
  {
    converter<char32_t, lak::endian::little>();
  }
  else if (conv_to == "utf32be")
  {
    converter<char32_t, lak::endian::big>();
  }
  else
  {
    std::wcerr << LAK_BRIGHT_RED "unknown encoding '"
               << lak::to_wstring(conv_to) << "'" LAK_SGR_RESET "\n"
               << usage << "\n";
    return 1;
  }
}
