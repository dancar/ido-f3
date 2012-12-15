# ido-f3

An Emacs pluging utilizing ido-mode to quickly open files inside a predefined project group.

## Introduction

ido-f3 allows you to quickly find a file inside a project directory tree by preloading the entire tree as a list of file-names and using ido-mode to choose between them.
ido-f3 also allows you to easily switch between such projects, assuming all your projects are located in the same root directory.
It is possible to load a directory outside the root projects directory using *f3-load-project*.

## Requirements

- ido-mode
- common-lisp (cl)
Both of the above  ships with emacs 23.

## Usage
1. Define your *f3-projects-dir*, which is the root directory of the different projects you wish to be able to switch between.
1. Use *m-x f3-switch-project* to choose your current project. ido-f3 will then preload the entire project directory-tree to memory.
1. Use *m-x f3* to visit a file in your project.

It is highly recommended to bind *f3* and *f3-switch-project* to comfortable keys. I use x-c x-p and f8, respectively.
