#!/usr/bin/env ruby

Span = Struct.new("Span", :start, :size)
Import = Struct.new("Import", :from, :imports, :span)

module Collect
  None = 0
  DefaultImport = 1
  Import = 2
  From = 3
end

module Token
  CurlyOpen = "{"
  CurlyClose = "}"
  Comma = ","
  SemiColon = ";"
  Comment = "//"
  CommentMultilineStart = "/*"
  CommentMultilineEnd = "*/"
  Import = "import"
  From = "from"
  As = "as"
  Asterisk = "*"
end

class Lexer
  attr_accessor :parsed
  def initialize(src)
    @src = src
    @content = src.dup
    @cursor = 0
    @parsed = []
  end

  def chop!(count = 1)
    @cursor += count
    @src.slice!(0, count)
  end

  def empty?(string)
    string.strip.empty?
  end

  def prev_empty?
    @cursor == 0 ? true : self.empty?(@content[@cursor - 1])
  end

  def token?(token)
    self.prev_empty? && @src.start_with?(token) && self.empty?(@src[token.length])
  end

  def show
    @parsed.each do |item|
      puts "from: #{item.from}"
      puts "imports: #{item.imports.inspect}"
      puts "span: #{item.span.start} to #{item.span.start + item.span.size}\n\n"
    end
  end

  def parse!
    symbol = ""
    collect = Collect::None
    start = 0
    imports = []

    while @src.length > 0
      if self.token?(Token::Import)
        start = @cursor
        collect = Collect::DefaultImport
        self.chop!(6)
        next
      end

      if self.token?(Token::As) && symbol.length > 0
        symbol << ":as:"
        self.chop!(2)
        next
      end

      if self.token?(Token::From) && collect != Collect::From
        if collect == Collect::DefaultImport && symbol.length > 0
          imports << ":def:" + symbol
          symbol = ""
        end
        collect = Collect::From
        self.chop!(4)
        next
      end

      if @src.start_with?(Token::Comment)
        end_idx = @src.index("\n") || 2
        self.chop!(end_idx)
        next
      end

      if @src.start_with?(Token::CommentMultilineStart)
        end_idx = @src.index(Token::CommentMultilineEnd) || @src.length
        self.chop!(end_idx + 2)
        next
      end

      char = self.chop!()
      next if char.strip.empty?

      if char == Token::CurlyOpen && collect == Collect::DefaultImport
        collect = Collect::Import
      elsif char == Token::CurlyClose
        if symbol.length > 0 && collect == Collect::Import
          imports << symbol
          symbol = ""
        end
        collect = Collect::None
      elsif char == Token::Comma && symbol.length > 0
        if collect == Collect::DefaultImport
          symbol = "default:" + symbol
        end
        imports << symbol
        symbol = ""
      elsif char == Token::SemiColon
        if symbol.length > 0 && collect == Collect::From && imports.length > 0
          from = symbol.gsub("\"", "")
          span = Span.new(start, @cursor - start)
          @parsed << Import.new(from, imports, span)
          imports = []
        end
        collect = Collect::None
        symbol = ""
      elsif collect != Collect::None
        symbol << char
      end
    end
  end
end
