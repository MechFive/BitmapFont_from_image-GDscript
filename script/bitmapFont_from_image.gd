
#####################################################################################
# MIT License
#
# Copyright (c) 2019 MechFive
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#####################################################################################
#
# script for creating monospaced bitmap fonts from texture.
# tested in Godot 3.0.6 and 3.0.5
#
# attach this script to Node and fill the Font Texture field with the texture you
# want to create.
#
# you need to write a [texture_name].kmp file (example below) in same
# folder with the texture you wish to convert.
#
# You can now run the script and you should have bitmap font resource of your 
# texture in the same folder with your texture after script finishes.
#
# You can tweak your texture and reimport the texture and the font resource will
# update without having to run this script again (unless you add characters or
# change the cell they are).
#
# NOTE: this script is meant to be used as a custom importer for bitmap font so it
# is not recommeded to run it unless you need to create or modify that resource.
#
######################### [texture_name].kmp ########################################
#
# lines beginning with # are regardeds as comments and will be ignored.
# empty lines are ignored also.
#
# first non comment or non empty line is for texture size x and y accordingly.
# then type the symbols as they appear in your texture.
# do line break for next row, ignore empty cells (if any) in your texture.
# save this file as [texture_name].kmp in same folder as your texture.
#
# NOTIFICATION: dont make #(hashtag) symbol in the first cell of any row in
# your texture, because this file would dismiss that row as a comment.
#
# Example file [texture_name].kmp
#4, 4
# !?:.,
#01234567
#89
#abcdefgh
#ijklmnop
#qrstuvwx
#yz
#
#####################################################################################


extends Node

export (Texture) var font_texture
var font = BitmapFont.new()
var char_size = Vector2()
var lines = []
var font_path
var key_map_file_extension = ".kmp"

func _ready():
	if font_texture != null:
		font.add_texture(font_texture)
		font_path = font_texture.get_path()
		font_path.erase(font_path.find_last("."), font_path.length() - font_path.find_last("."))
		if get_keymap():
			parse_line_to_vector2(lines.pop_front())
			make_font()
			save_font()
	else:
		print("please assign font texture.")

func get_keymap():
	var key_map = File.new()
	if key_map.open(str(font_path + key_map_file_extension), key_map.READ) == 0:
		while not key_map.eof_reached():
			var line = key_map.get_line()
			if not line.begins_with("#") and not line.empty():
				lines.append(line)
		key_map.close()
		return true
	else:
		print("something went wrong loading .kmp file, please ensure file exist and the name is consistent with font texture.")
		return false

func parse_line_to_vector2(line):
	var parsed_values = ["",""]
	var parser_i = 0
	for c in line:
		if c.is_valid_integer():
			parsed_values[parser_i] += c
		if c == ",":
			parser_i = 1
	char_size = Vector2(int(parsed_values[0]), int(parsed_values[1]))

func make_font():
	for line in range(lines.size()):
		var i = 0
		for chr in lines[line]:
			var t = chr.to_utf8()
			var cpr = Rect2(Vector2(i, line) * char_size, char_size)
			font.add_char(t[0], 0, cpr)
			i += 1

func save_font():
	var export_file = str(font_path + ".font")
	ResourceSaver.save(export_file, font)
	print(export_file, " created!")
