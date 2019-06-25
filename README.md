# FormalCourseExercise
Exercise of Formal Verification Courseware

## Usage
- Install prerequisites

```bash
sudo apt-get install build-essential clang bison flex \
    libreadline-dev gawk tcl-dev libffi-dev git \
    graphviz xdot pkg-config python3 libboost-system-dev \
    libboost-python-dev libboost-filesystem-dev
```
- Install all tools

```bash
git submodule update --init --recursive
./install.sh
```
- Add ./bin to $path

```bash
source sourceMe.bashrc
```

- Enjoy your exercise
