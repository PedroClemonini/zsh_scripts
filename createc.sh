#!/bin/bash
flag=false
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
   cat <<EOF > "$projectname/Makefile"
CC = clang
CFLAGS = -Wall -Wextra -Iinclude
SRC_DIR = src
INCLUDE_DIR = include
BUILD_DIR = build
TARGET = code

SRCS := \$(wildcard \$(SRC_DIR)/*.c)
OBJS := \$(patsubst \$(SRC_DIR)/%.c,\$(BUILD_DIR)/%.o,\$(SRCS))
DEPS := \$(wildcard \$(INCLUDE_DIR)/*.h)

\$(BUILD_DIR)/\$(TARGET): \$(OBJS)
\t\$(CC) \$(CFLAGS) -o \$@ \$^

\$(BUILD_DIR)/%.o: \$(SRC_DIR)/%.c \$(DEPS)
\t@mkdir -p \$(BUILD_DIR)
\t\$(CC) \$(CFLAGS) -c -o \$@ \$<

run: \$(BUILD_DIR)/\$(TARGET)
\t@\$(BUILD_DIR)/\$(TARGET)

clean:
\trm -rf \$(BUILD_DIR)

.PHONY: clean
EOF
}

    while getopts ':p:l:h' opt;
        do
            case $opt in
                p)  
                    projectname=$OPTARG
                    createbasic
                    createmakefile
                    flag=true
                ;;

                l)
                    if [ "$flag" = false ]; then
                        echo ""
                        echo "Error: You need to specify a project name" 
                        echo "Usage: $0 [-p projectname] [-l library] [-h]" 
                        echo ""
                        exit 1
                    fi
                    set -f # disable glob
                    IFS=' ' # split on space characters
                    libraries+=($OPTARG)
                    createlibraries
                ;;

                h) 
                    echo ""
                    echo "This script is used to automatize the creation of c project "
                    echo "script name : createc.sh "
                    echo "flag Project : -p [projectname] (OBRIGATORY - create the project directory and the basic structure)"
                    echo "flag Libraries : -l [\"your_libraries\"] (OPTIONAL - create libraries .h and .c files with the names choosen)"
                    echo ""
                ;;



            esac
        done



shift $(($OPTIND - 1))
