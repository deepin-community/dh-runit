#!/bin/sh

#run with
#autopkgtest ../dh-runit_2.17.2_all.deb ../runit-helper_2.17.2_all.deb  . --test-name=command1 -- qemu ../autopkgtest.img

rc=0
rcadd() { printf '%s\n' "$*"; rc=$((rc+1)); }
fail() { rcadd "fail: $*"; }
warn() { printf '%s\n' "warn: $*"; }
info() { printf '%s\n' "info: $*"; }
fatal() { printf '%s\n' "fatal: $*"; exit 1; }
do_cleanup() { rm -rf "$TMPDIR" ; cd "$CURDIR"; }
trap  do_cleanup  EXIT

echo "running dh-runit main testsuite:"

dhrunit=dh_runit
CURDIR=$PWD
TMPDIR=$(mktemp -d)
[ -d "$TMPDIR" ] || fatal "failed to create tmpdir"
TESTDIR=$CURDIR/t/out
mkdir -p "$TESTDIR" || fatal "failed to create $TESTDIR test dir"

#autopkgtest var
if [ -z "$AUTOPKGTEST" ]; then
    #not run from autopkgtest
    export DH_AUTOSCRIPTDIR=$CURDIR
    export DH_RUNIT_DATADIR=$CURDIR/data
    dhrunit=$CURDIR/dh_runit
fi

cp -a ./t/base/default/debian "$TMPDIR"
for dir in ./t/checks/* ; do
    cp -a "$dir" "$TMPDIR"
    cp -a "$TMPDIR/debian" "$TMPDIR/${dir##*/}"
    cp -a "$TMPDIR/${dir##*/}" "$TESTDIR" || fatal "failed to copy ${dir##*/} to $TESTDIR test dir"
    echo "cp ${dir##*/} to $TESTDIR: done"
done

#TODO the original testrunner.hs haskell testsuite after merging the base dir with each test, tar
# and copies to $TESTDIR; then untar each test archive and then run dh-runit: WHY bother with tar?
# tar would be an extra build dep for this test and I don't understand the purpose so we don't do thart for now..
#NOTE: one difference is that this test does not generate package.debhelperlog inside each test directory, while
#the haskell testsuite generates it with one line content 'dh_runit'

cd "$TESTDIR"
for dir in ./* ; do
    #echo "current dir is $PWD"
    cd "$dir"
    if ! $dhrunit ; then
        warn "dh_runit run with $dir test returned non zero"
    fi
    if ! prove ./check > "../${dir##*/}.log" ; then
        fail "test $dir failed!"
    else
        info "test $dir : ok"
    fi
    cd "$TESTDIR"
done

echo "TEST RESULT: $rc tests failed"
echo "..done"
exit "$rc"
