#!/bin/bash

DIST_DIR="./rjr_temp_dir"


skip=false
for i in $(seq 1 $(($# - 1))); do
    [ $skip = true ] && skip=false && continue 
    if [[ "${!i}" == "-cp" && -z "$classpath"  ]]; then
        next_index=$((i + 1))
        classpath=${!next_index}
    fi
    [[ "${!i}" != "-d" ]] && args="$args ${!i}" || skip=true    
done

[[ -z "$classpath"  && -n "$CLASSPATH" ]] && classpath=$CLASSPATH

args="$args -d $DIST_DIR ${!#}"
[ -d "$DIST_DIR" ] && rm -rf "$DIST_DIR"
mkdir "$DIST_DIR"

file_name=$(basename ${!#})
resolved_class=$(echo "$file_name" | sed 's/\.[^.]*$//')
resolved_package=$(grep -m 1 '^package' ${!#} | sed 's/package //; s/;//')
[ -n "$resolved_package" ] && resolved_class="$resolved_package.$resolved_class"

[ -n $JAVA_HOME ] && javac="$JAVA_HOME/bin/javac"; java="$JAVA_HOME/bin/java"

$javac $args && $java -cp "$classpath:$DIST_DIR" $resolved_class

rm -rf "$DIST_DIR"
