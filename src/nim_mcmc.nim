import std/random
import std/sugar
import std/sequtils
import std/strutils

const lowerCaseAscii = 97..122

# Direct translation of my C++ implementation
# as a first version
# https://github.com/mrtkp9993/Cpp-Examples/blob/master/lib/numericCppExamples/metropolisHastings.h
proc mcmc(fun: (float) -> float, ncount: int, burnInPeriod: int): seq[float] =
  randomize()
  result = newSeq[float](ncount + burnInPeriod)
  result[0] = 1.0

  for i in countup(1, ncount + burnInPeriod - 1):
    var currentx: float = result[i - 1]
    var proposedx: float = currentx + gauss()
    var A: float = fun(proposedx) / fun(currentx)
    if (rand(1.0) < A):
      result[i] = proposedx
    else:
      result[i] = currentx

  delete(result, 0..burnInPeriod - 1)
  return result

proc writeToFile(res: seq[float]) =
  var fname = $6.newSeqWith(lowerCaseAscii.rand.char).join & ".txt"
  let f = open(fname, fmWrite)
  defer: f.close()

  for r in res:
    f.writeLine(r)
