extends Node

#level
var level := 1
var completed_levels := []

var columns : int
var rows : int

var shooters : Array
var tanks : Array
var empties : Array

#grid
var grid_width := 110
var grid_height := 110
var offset := 65

#other
var movement
var time := 0
var enemies_left : int
var is_game_end = false
