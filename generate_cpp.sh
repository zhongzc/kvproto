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
protoc -I${GRPC_INCLUDE} --cpp_out ../cpp/kvproto *.proto || exit $?
protoc -I${GRPC_INCLUDE} --grpc_out ../cpp/kvproto --plugin=protoc-gen-grpc=`which grpc_cpp_plugin` *.proto || exit $?
pop

push include
protoc -I${GRPC_INCLUDE} --cpp_out ../cpp/kvproto *.proto || exit $?
pop

echo "formating cpp code..."
# Remove useless gogoproto includes and references. It's used by Golang only.
sed -i '' '/gogoproto/d' cpp/kvproto/*.h cpp/kvproto/*.cc
clang-format -i cpp/kvproto/*.h cpp/kvproto/*.cc

