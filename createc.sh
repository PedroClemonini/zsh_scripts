#!/bin/bash
createproject(){
     {
    echo "#include <stdio.h>"
    echo "#include <stdlib.h>"
     }> "$projectname/src/main.c"

    for lib in "${libraries[@]}"; do
        echo "#include \"$lib.h\"" >>"$projectname/src/main.c"
    done
    {
    echo ""
    echo 'int main(void){'
    echo ""
    echo 'return 0;'
    echo "}"
    } >> "$projectname/src/main.c"
}

createlibraries(){
    for val in "${libraries[@]}"; do
        touch "$projectname/include/$val.h"    
            upper_val=$(echo $val | tr '[a-z]' '[A-Z]')
            {
            echo "#ifndef ${upper_val}_H" 
            echo "#define ${upper_val}_H"
            echo "#endif" 
            } > "$projectname/include/$val.h"

        touch "$projectname/src/$val.c"
            echo "#include \"${val}.h\" " > "$projectname/src/$val.c"
            createproject
            
    done
}

createbasic(){
    mkdir "$projectname"
    mkdir -p "$projectname/src" "$projectname/include"

    {
    echo "#include <stdio.h>"
    echo "#include <stdlib.h>"
    echo ""
    echo 'int main(void){'
    echo ""
    echo 'return 0;'
    echo "}"
    } > "$projectname/src/main.c"

}


createmakefile(){

touch "$projectname/Makefile"
    echo '
    CC = clang
    CFLAGS = -Wall -Wextra -Iinclude
    SRC_DIR = src
    INCLUDE_DIR = include
    BUILD_DIR = build
    TARGET = code

    SRCS = $(wildcard $(SRC_DIR)/*.c)
    OBJS = $(SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
    DEPS = $(wildcard $(INCLUDE_DIR)/*.h)

    $(BUILD_DIR)/$(TARGET): $(OBJS)
        $(CC) $(CFLAGS) -o $@ $^

    $(BUILD_DIR)/%.o: $(SRC_DIR)/%.c $(DEPS)
        @mkdir -p $(BUILD_DIR)
        $(CC) $(CFLAGS) -c -o $@ $<

    run: $(BUILD_DIR)/$(TARGET)
        @./$(BUILD_DIR)/$(TARGET)


    clean:
        rm -rf $(BUILD_DIR)

    .PHONY: clean
    ' > "$projectname/Makefile"
}

    while getopts ':p:l:' opt;
        do
            case $opt in
                p)  
                    projectname=$OPTARG
                    createbasic
                    createmakefile
                ;;

                l)
                    set -f # disable glob
                    IFS=' ' # split on space characters
                    libraries+=($OPTARG)
                    createlibraries
                ;;
                
                \?) 
                    echo "Usage createc.sh -p [projectname] -l [\"your_libraries\"]"
                    exit 1;;
            esac
        done
shift $(($OPTIND - 1))
