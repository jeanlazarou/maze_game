Maze Game
=========

Maze game presents a fame where the player moves through a maze searching 
for the exit. The maze grids are randomly generated using theseus, a maze 
generator (from https://github.com/jamis/theseus.git).

The player can:

* save the current maze and replay it at a later time,
* load a demo maze (10 by 10), start the game with -d option,
* force the generation of a new maze at any moment,
* start the game with a timer
 
The project
-----------

It currently displays a Text UI using Unix curses. As it only runs on 
Unix-like systems, I added a basic implementation of the curses library 
for jRuby using the Java/Swing GUI layer, so that it can run on all systems. 
The curses support is limited to make the game run and is not 'curses' 
compatible. I published it as a gem (https://github.com/jeanlazarou/jruby_curses).

## How to run the game

To run the game you need to first install theseus, then with RMI 1.9.2:

```bash
ruby maze_game.rb
```
  
With jRuby:

Install the "jruby_curses" gem (see above) and then use it as

```bash
jruby --1.9 maze_game.rb
```

## "maze_game.rb" script usage

Here is the usage message of the script:

    Usage: maze_game.rb [options]

    Where options include:
        -d, --demo                       Use the demo maze
        -t, --time                       Display ellapsed time
        -p, --position                   Display cursor position
        -f, --file maze_file.yml         Load a saved maze from the given YAML file
        -w, --width w                    Width for the maze to generate (defaults to 20)
        -h, --height h                   Height for the maze to generate (defaults to 20)
        -?, --help                       Show this message


## Notes

* Unfortunately, both MRI 1.9.2 and 1.9.3 did not include 'curses' after
installing them with rvm, I managed to make it work by copying the 
`curses.so` file from 1.9.1 to `lib/ruby/1.9.1/i686-linux`.
* As of Ruby 2.1 the curses library is not part of the standard library anymore, 
and is available as a Ruby gem ([https://github.com/ruby/curses](https://github.com/ruby/curses)).
* The _curses_ gem also works fine with the [Rubinius](http://rubini.us/) implementation of Ruby.

\- Jean Lazarou
