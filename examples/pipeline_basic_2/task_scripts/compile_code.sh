#!/bin/sh

echo "Creating a compiled artifact that is a text file called product.txt"
uname -a
echo "check the contents of the my-build-artifacts folder..."
ls "my-build-artifacts"
echo "..nothing here"

echo "compiling the code..."
#this stub represents the compilation step (eg some npm/maven compilation etc that produces build artifacts)
echo "this is the compiled artifact" > "my-build-artifacts/product.txt"

echo "check the contents of the my-build-artifacts folder again"
ls "my-build-artifacts"

cat ".git/ref"
