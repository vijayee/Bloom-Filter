use "Murmur3"
use "collections"
use "Bitset"

primitive OptimalSizeForNP
  fun apply (n: USize, p: F64) : (USize, USize) =>
  let m: F64 = ((n.f64() * p.log()) /(1 / F64(2).pow(F64(2).log())).log()).ceil()
  let r: F64 = m / n.f64()
  let k: F64 = (F64(2).log() * r).round()
  (m.usize(), k.usize())


class BloomFilter
  let _size: USize
  let _hashCount: USize
  let _seed1: U32 = 1
  let _seed2: U32 = 2
  let _bits: Bitset
  var _count: USize = 0


  new create(size': USize, hashCount: USize) =>
      _size = size'
      _hashCount = hashCount
      var bytes = _size / 8
      if (_size % 8) > 0 then
        bytes = bytes + 1
      end
      _bits = Bitset(bytes)

  fun ref add(data: Array[U8] box) ? =>
    let a = Murmur32.hash(data, _seed1)?
    let b = Murmur32.hash(data, _seed2)?
    var newItem : Bool = false
    for i in Range(0, _hashCount) do
      let index: USize = ((a + (i.u32() * b) + i.f64().pow(2).u32()) % _size.u32()).usize()
      if (not newItem) and (not (_bits(index)? = true)) then
        newItem = true
      else
        _bits.set(index, true)?
      end
    end
    if newItem then
      _count = _count + 1
    end

  fun contains(data: Array[U8] box) : Bool =>
    try
      let a = Murmur32.hash(data, _seed1)?
      let b = Murmur32.hash(data, _seed2)?
      for i in Range(0, _hashCount) do
        let index: USize = ((a + (i.u32() * b) + i.f64().pow(2).u32()) % _size.u32()).usize()
        if not _bits(index)? then
          return false
        end
      end
      true
    else
     false
    end

  fun size(): USize =>
    _size

  fun count(): USize =>
    _count
