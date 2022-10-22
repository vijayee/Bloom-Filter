use "pony_test"
use ".."
use "collections"
use "time"
use "random"

actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)
  new make () =>
    None
  fun tag tests(test: PonyTest) =>
    test(_TestOptimalSizeForNP)
    test(_TestBloomFilter)

primitive RandomBytes
  fun apply(size: USize): Array[U8] =>
    let now = Time.now()
    var gen = Rand(now._1.u64(), now._2.u64())
    var bytes: Array[U8] = Array[U8](size)
    for j in Range(0, size) do
      bytes.push(gen.u8())
    end
    bytes

class iso _TestOptimalSizeForNP is UnitTest
  fun name(): String => "Optimal Size For N and P"
  fun apply(t: TestHelper) =>
    (let m: USize, let k: USize) = OptimalSizeForNP(4000, 0.0000001)
    t.assert_true(m == 134191)
    t.assert_true(k == 23)

class iso _TestBloomFilter is UnitTest
  fun name(): String => "Testing Bloom Filter"
  fun apply(t: TestHelper) =>
    let count: USize = 1000000
    let size: USize = 4
    let fpr: F64 = 0.0000001
    let fixtures: Array[Array[U8] val] = Array[Array[U8] val](count)

    for i in Range(0, count) do
      fixtures.push(recover val RandomBytes(size) end)
    end
    (let m: USize, let k: USize) = OptimalSizeForNP(count, fpr)
    let bloom: BloomFilter = BloomFilter(m,k)
    for key in fixtures.values() do
      try
        bloom.add(key)?
      else
        t.fail("obscure failure")
      end
    end

    for key in fixtures.values() do
      t.assert_true(bloom.contains(key))
    end
