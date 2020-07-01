#!/bin/bash
inkscape cover.svg --export-png=cover.png
convert cover.png -quality 90 Quadrupeds-Illinois.cover.jpg
inkscape cover.svg --export-height=240 --export-png=thumbnail.png
convert thumbnail.png -quality 90 Quadrupeds-Illinois.thumbnail.jpg
