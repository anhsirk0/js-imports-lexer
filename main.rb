#!/usr/bin/env ruby

require_relative "lexer.rb"

# src = %{import {
#   Some as Other,
#   imported,
#   Maybe,
#   toMaybe,
#   Stuff,
#   MoreStuff,
#   smallStuff,
#   asTestUtils,
#   froming,
# } from "test";
# // some comments
# import { Some2, Maybe2, Stuff2, MoreStuff2 } from "test2";
# // import { Some3, Maybe3, Stuff3, MoreStuff3 } from "test3";

# import React, { FC, useState } from "react";
# import * as All from "all";
# import some from "some";

# console.log(123);
# }
src = 'import React, { FC , useState } from "react";'

lex = Lexer.new(src)
lex.parse!
lex.show
