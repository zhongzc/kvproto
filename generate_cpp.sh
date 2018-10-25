#!/bin/bash

. ./common.sh

if ! check_protoc_version; then
	exit 1
fi

echo "generate cpp code..."

KVPROTO_ROOT=`pwd`
GOGO_ROOT=${KVPROTO_ROOT}/_vendor/src/github.com/gogo/protobuf
GRPC_INCLUDE=.:${GOGO_ROOT}:${GOGO_ROOT}/protobuf:../include

push proto
protoc -I${GRPC_INCLUDE} --cpp_out ../cpp *.proto || exit $?
protoc -I${GRPC_INCLUDE} --grpc_out ../cpp --plugin=protoc-gen-grpc=`which grpc_cpp_plugin` *.proto || exit $?
pop

echo "formating cpp code..."

push cpp
clang-format -i *.h *.cc
pop