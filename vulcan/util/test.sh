# /vulcan/util/test.sh

TEST_INDEX=1
GCOV_PATH=$GITHUB_WORKSPACE/gcov

_create_gcov_directory() {
	rm -rf $GCOV_PATH
	mkdir $GCOV_PATH
}

_write_test_result() {
	if [ ! $? -eq 0 ];
	then
		echo failed > $GCOV_PATH/$TEST_INDEX/result.test
	else
		echo passed > $GCOV_PATH/$TEST_INDEX/result.test
	fi
}

_clean_after_collect_gcov() {
	# find $GITHUB_WORKSPACE/vulcan_target ! \( -path '*test*' -prune \) -type f -name "*.o" -exec gcov --preserve-paths {} \; > /dev/null 2>/dev/null
	# mv $GITHUB_WORKSPACE/vulcan_target/*.gcov $GCOV_PATH/$TEST_INDEX
	lcov --directory=$GITHUB_WORKSPACE/vulcan_target --output-file $GCOV_PATH/$TEST_INDEX/generated.info --capture -f
	genhtml $GCOV_PATH/$TEST_INDEX/generated.info --output-directory=$GCOV_PATH/$TEST_INDEX/html
	find $GITHUB_WORKSPACE/vulcan_target -type f -name "*.gcda" -delete
}

_split_test() {
	for UNIT_TEST in $(sh -c "$VULCAN_YML_TEST_LIST | grep test_")
	do
		echo "Measuring coverage for $UNIT_TEST\n"
		mkdir $GCOV_PATH/$TEST_INDEX
		sh -c "${VULCAN_YML_TEST_COVERAGE_COMMAND//\?/$UNIT_TEST}"
		
		_write_test_result
		_clean_after_collect_gcov
		
		TEST_INDEX=$(( $TEST_INDEX + 1 ))
	done
}

_create_gcov_directory
_split_test
