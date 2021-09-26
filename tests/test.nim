import unittest
import impl

type T = object
  a: int

impl T:
  proc new {.ctor.} =
    this.a = 10
  proc new*(a: int) {.ctor.} =
    this.a = a
  
  proc sqr: int = this.a * this.a
  proc mul(x: int): int = this.a * x

  proc mulBy*(x: int) {.mut.} =
    this.a *= x

test "impl and ctor":    
  check T.new.sqr == 100
  check T.new(3).mul(4) == 12

  var x: T
  new x
  check x.a == 10

  x.mulBy(3)
  check x.a == 30
