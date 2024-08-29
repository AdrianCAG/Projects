import org.example.*
import org.junit.Assert.*
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4


@RunWith(JUnit4::class)
class testMUPL {

    @Test
    fun testKotlinListToMuplList() {
        val result = kotlinListToMuplList(listOf<MUPL<Any>>())
        val result2 = kotlinListToMuplList(listOf(int(3)))
        val result3 = kotlinListToMuplList(listOf(int(3), int(4)))
        val result4 = kotlinListToMuplList(listOf(int(3), int(4), int(5)))

        assertEquals(auint, result)
        assertEquals(apair(int(3), auint), result2)
        assertEquals(apair(int(3), apair(int(4), auint)), result3)
        assertEquals(apair(int(3), apair(int(4), apair(int(5), auint))), result4)
    }

    @Test
    fun testMuplListToKotlinList() {
        val result = muplListToKotlinList(auint)
        val result2 = muplListToKotlinList(apair(int(4), auint))
        val result3 = muplListToKotlinList(apair(int(4), apair(int(5), auint)))

        assertEquals(listOf<MUPL<Any>>(), result)
        assertEquals(listOf(int(4)), result2)
        assertEquals(listOf(int(4), int(5)), result3)
    }

    @Test
    fun testEnvlookup() {
        val result = envlookup(listOf(Pair("x", int(6))), "x")
        val result2 = envlookup(listOf(Pair("w", int(3)), Pair("y", int(10))), "y")

        assertEquals(int(6), result)
        assertEquals(int(10), result2)
    }

    @Test
    fun testIfGreater() {
        val result = evalExp(ifgreater(int(3), int(4), int(3), int(2)))
        val result2 = evalExp(ifgreater(int(4), int(3), int(3), int(2)))

        assertEquals(int(2), result)
        assertEquals(int(3), result2)
    }

    @Test
    fun testMlet() {
        val result = evalExp(mlet("x", int(1), add(int(5), vaar("x"))))
        val result2 = evalExp(mlet("x", int(1), add(vaar("x"), vaar("x"))))

        assertEquals(int(6), result)
        assertEquals(int(2), result2)
    }

    @Test
    fun testCall() {
        val result = evalExp(call(func("#f", "x", int(7)), int(1)))
        val result2 = evalExp(call(func("#f", "x", add(vaar("x"), int(7))), int(1)))
        val result3 = evalExp(call(closure(emptyList(), func("#f", "x", add(vaar("x"), int(7)))), int(1)))
        val result4 = evalExp(call(closure(listOf(Pair("y", int(7))), func("#f", "x", add(vaar("x"), vaar("y")))), int(1)))
        val result5 = evalExp(call(closure(emptyList(), func("hello", "x", add(vaar("x"), int(7)))), int(1)))

        assertEquals(int(7), result)
        assertEquals(int(8), result2)
        assertEquals(int(8), result3)
        assertEquals(int(8), result4)
        assertEquals(int(8), result5)
    }

    @Test
    fun testApair() {
        val result = evalExp(apair(int(2), int(1)))
        val result2 = evalExp(apair(add(int(2), int(3)), int(1)))
        val result3 = evalExp(apair(int(1), add(int(2), int(3))))
        val result4 = evalExp(apair(func("#f", "x", add(vaar("x"), int(7))), int(5)))

        assertEquals(apair(int(2), int(1)), result)
        assertEquals(apair(int(5), int(1)), result2)
        assertEquals(apair(int(1), int(5)), result3)
        assertEquals(apair(closure(emptyList(), func("#f", "x", add(vaar("x"), int(7)))), int(5)), result4)
    }

    @Test
    fun testFst() {
        val result = evalExp(fst(apair(int(2), int(1))))
        val result2 = evalExp(fst(apair(add(int(2), int(3)), int(1))))
        val result3 = evalExp(fst(apair(func("#f", "x", add(vaar("x"), int(7))), int(5))))

        assertEquals(int(2), result)
        assertEquals(int(5), result2)
        assertEquals(closure(emptyList(), func("#f", "x", add(vaar("x"), int(7)))), result3)
    }

    @Test
    fun testSnd() {
        val result = evalExp(snd(apair(int(1), int(2))))
        val result2 = evalExp(snd(apair(add(int(2), int(3)), int(1))))
        val result3 = evalExp(snd(apair(func("#f", "x", add(vaar("x"), int(7))), int(5))))

        assertEquals(int(2), result)
        assertEquals(int(1), result2)
        assertEquals(int(5), result3)
    }

    @Test
    fun testIsaunit() {
        val result = evalExp(isaunit(closure(emptyList(), func("#f", "x", auint))))
        val result2 = evalExp(isaunit(add(int(2), int(3))))
        val result3 = evalExp(isaunit(auint))

        assertEquals(int(0), result)
        assertEquals(int(0), result2)
        assertEquals(int(1), result3)
    }

    @Test
    fun testIfaunit() {
        val result = evalExp(ifaunit(int(1), int(2), int(3)))
        val result2 = evalExp(ifaunit(auint, int(2), int(3)))
        val result3 = evalExp(ifaunit(auint, add(int(2), int(3)), int(3)))

        assertEquals(int(3), result)
        assertEquals(int(2), result2)
        assertEquals(int(5), result3)
    }

    @Test
    fun testMletstar() {
        val result = evalExp(mletStar(listOf(Pair("x", int(10))), vaar("x")))
        val result2 = evalExp(mletStar(listOf(Pair("x", int(10)), Pair("y", int(5)), Pair("z", int(2))), vaar("z")))
        // simple translation of the above test
        val result3 = evalExp(mlet("x", int(10), mlet("y", int(5), mlet("z", int(2), vaar("z")))))
        val result4 = evalExp(mletStar(listOf(Pair("x", int(10)), Pair("y", int(5)), Pair("z", int(2))), vaar("y")))
        val result5 = evalExp(mletStar(listOf(Pair("x", int(10)), Pair("y", int(1))), add(vaar("x"), vaar("y"))))

        assertEquals(int(10), result)
        assertEquals(int(2), result2)
        assertEquals(int(2), result3)
        assertEquals(int(5), result4)
        assertEquals(int(11), result5)
    }

    @Test
    fun testIfeq() {
        val result = evalExp(ifeq(int(1), int(2), int(3), int(4)))
        val result2 = evalExp(ifeq(int(2), int(2), int(3), int(4)))
        val result3 = evalExp(ifeq(int(2), int(1), int(3), int(4)))
        val result4 = evalExp(ifeq(int(3), int(2), int(3), int(4)))
        val result5 = evalExp(ifeq(int(2), int(3), int(3), int(4)))
        val result6 = evalExp(ifeq(add(int(3), int(1)), add(int(2), int(2)), add(int(3), int(2)), int(4)))

        assertEquals(int(4), result)
        assertEquals(int(3), result2)
        assertEquals(int(4), result3)
        assertEquals(int(4), result4)
        assertEquals(int(4), result5)
        assertEquals(int(5), result6)
    }

    @Test
    fun testMuplMap() {
        val result = evalExp(call(call(muplMap, func("#f", "x", add(vaar("x"), int(7)))), apair(int(1), auint)))

        assertEquals(apair(int(8), auint), result)
    }

    @Test
    fun testMuplMapAddN() {
        val result = muplListToKotlinList(evalExp(call(call(muplMapAddN, int(7)),
            kotlinListToMuplList(listOf(int(3), int(4), int(9))))))

        assertEquals(listOf(int(10), int(11), int(16)), result)
    }

    @Test
    fun testComputeFreeVars() {
        val result = computeFreeVars(vaar("x"))
        val result2 = computeFreeVars(int(5))
        val result3 = computeFreeVars(add(vaar("x"), vaar("y")))
        val result4 = computeFreeVars(ifgreater(vaar("x"), vaar("y"), vaar("z"), int(0)))
        val result5 = computeFreeVars(func("#f", "x", add(vaar("x"), vaar("y"))))
        val result6 = computeFreeVars(func("f", "x", add(vaar("x"), vaar("y"))))
        val result7 = computeFreeVars(call(vaar("f"), vaar("x")))
        val result8 = computeFreeVars(mlet("y", vaar("x"), add(vaar("y"), vaar("z"))))
        val result9 = computeFreeVars(apair(vaar("x"), vaar("y")))
        val result10 = computeFreeVars(fst(vaar("p")))
        val result11 = computeFreeVars(snd(vaar("p")))
        val result12 = computeFreeVars(auint)
        val result13 = computeFreeVars(isaunit(vaar("x")))
        // The variables y and z are free because they are not bound by the function's formal parameter x or the function name f.
        // "Function with Multiple Free Variables"
        val result14 = computeFreeVars(func("f", "x", add(vaar("x"), add(vaar("y"), vaar("z")))))
        // The variable y is bound in the mlet expression, so it is not considered free in the body. However, x and z remain free.
        // "Let Binding with Free Variable Removal"
        val result15 = computeFreeVars(mlet("y", add(vaar("x"), vaar("z")), add(vaar("y"), vaar("z"))))
        // In the outer mlet, y is bound, so it isn't free in the inner expressions.
        // In the inner mlet, z is bound, so it isn't free in the body.
        // x and w remain free as they are not bound in any scope.
        // "Nested Let Bindings"
        val result16 = computeFreeVars(mlet("y", vaar("x"),
            mlet("z", add(vaar("y"), vaar("w")),
                add(vaar("x"), vaar("z")))))
        // The function itself has y as a free variable.
        // The function call has a and b as free variables from the argument.
        // "Function Call with Free Variables in Arguments"
        val result17 = computeFreeVars(call(func("#f", "x", add(vaar("x"), vaar("y"))),
            add(vaar("a"), vaar("b"))))
        // All variables x, y, f, and z are free in their respective sub-expressions and are unioned together.
        // "Pair Expression with Nested Free Variables"
        val result18 = computeFreeVars(apair(add(vaar("x"), vaar("y")), call(vaar("f"), vaar("z"))))
        // z is bound in the mlet within the else branch of the ifgreater, so it's not free there.
        // x, y, and w remain free.
        // "Complex Ifgreater Expression"
        val result19 = computeFreeVars(ifgreater(vaar("x"), int(0),
            add(vaar("y"), vaar("z")),
            mlet("z", vaar("x"), vaar("w"))))
        // g (the function's name) and x (the formal parameter) are bound and thus not free in the body.
        // z remains free since it is only bound within the mlet's right-hand side.
        // "Removal of Free Variables in Named Function"
        val result20 = computeFreeVars(func("g", "x",
            mlet("y", vaar("z"),
                add(vaar("x"), vaar("g")))))
        // "Unit and Isaunit Combination"
        val result21 = computeFreeVars(isaunit(mlet("x", auint, add(vaar("y"), vaar("x")))))


        assertEquals(vaar("x"), result)
        assertEquals(int(5), result2)
        assertEquals(add(vaar("x"), vaar("y")), result3)
        assertEquals(ifgreater(vaar("x"), vaar("y"), vaar("z"), int(0)), result4)
        assertEquals(funChallenge("#f", "x", add(vaar("x"), vaar("y")), setOf("y")), result5)
        assertEquals(funChallenge("f", "x", add(vaar("x"), vaar("y")), setOf("y")), result6)
        assertEquals(call(vaar("f"), vaar("x")), result7)
        assertEquals(mlet("y", vaar("x"), add(vaar("y"), vaar("z"))), result8)
        assertEquals(apair(vaar("x"), vaar("y")), result9)
        assertEquals(fst(vaar("p")), result10)
        assertEquals(snd(vaar("p")), result11)
        assertEquals(auint, result12)
        assertEquals(isaunit(vaar("x")), result13)
        assertEquals(funChallenge("f", "x", add(vaar("x"), add(vaar("y"), vaar("z"))), setOf("y", "z")), result14)
        // Some of them are not in a function body, just expressions (that's why free variables differ).
        // [x, z]
        assertEquals(mlet("y", add(vaar("x"), vaar("z")), add(vaar("y"), vaar("z"))), result15)
        // [x, w]
        assertEquals(mlet("y", vaar("x"), mlet("z", add(vaar("y"), vaar("w")), add(vaar("x"), vaar("z")))), result16)
        // [y, a, b]
        assertEquals(call(funChallenge("#f", "x", add(vaar("x"), vaar("y")), setOf("y")), add(vaar("a"), vaar("b"))), result17)
        // [x, y, f, z]
        assertEquals(apair(add(vaar("x"), vaar("y")), call(vaar("f"), vaar("z"))), result18)
        // [x, y, z, w]
        assertEquals(ifgreater(vaar("x"), int(0), add(vaar("y"), vaar("z")), mlet("z", vaar("x"), vaar("w"))), result19)
        // [z]
        assertEquals(funChallenge("g", "x", mlet("y", vaar("z"), add(vaar("x"), vaar("g"))), setOf("z")), result20)
        // [y]
        assertEquals(isaunit(mlet("x", auint, add(vaar("y"), vaar("x")))), result21)
    }

    @Test
    fun testEvalUnderEvnC() {
        // "Basic Integer"
        val result = evalExpC(int(42))
        // "Variable Binding and Lookup"
        val result2 = evalExpC(mlet("x", int(10), vaar("x")))
        // "Addition"
        val result3 = evalExpC(add(int(3), int(4)))
        // "If Greater (true branch)"
        val result4 = evalExpC(ifgreater(int(5), int(3), int(10), int(0)))
        // "If Greater (false branch)"
        val result5 = evalExpC(ifgreater(int(2), int(3), int(10), int(0)))
        // "Function Closure Pre-Transformation"
        val result6 = evalExpC(func("#f", "x", add(vaar("x"), int(5))))
        // "Function Closure Pre-Transformation"
        val result7 = evalExpC(func("#f", "x", add(int(3), int(5))))
        // "Function Call"
        val result8 = evalExpC(call(func("#f", "x", add(vaar("x"), int(5))), int(3)))
        // "Recursive Function"
        val result9 = evalExpC(call(func("fact", "n", ifgreater(vaar("n"), int(1),
            call(vaar("fact"), add(vaar("n"), int(-1))),
            vaar("n"))), int(3)))
        // "Let Binding"
        val result10 = evalExpC(mlet("y", int(5), add(vaar("y"), int(3))))
        // "Pair Creation"
        val result11 = evalExpC(apair(int(1), int(2)))
        // "First of Pair"
        val result12 = evalExpC(fst(apair(int(1), int(2))))
        // "Second of Pair"
        val result13 = evalExpC(snd(apair(int(1), int(2))))
        // "Unit Value"
        val result14 = evalExpC(auint)
        // "IsAUnit (true case)"
        val result15 = evalExpC(isaunit(auint))
        // "IsAUnit (false case)"
        val result16 = evalExpC(isaunit(int(42)))

        assertEquals(int(42), result)
        assertEquals(int(10), result2)
        assertEquals(int(7), result3)
        assertEquals(int(10), result4)
        assertEquals(int(0), result5)
        assertEquals(closure(emptyList(), funChallenge("#f", "x", add(vaar("x"), int(5)), emptySet())), result6)
        assertEquals(closure(emptyList(), funChallenge("#f", "x", add(int(3), int(5)), emptySet())), result7)
        assertEquals(int(8), result8)
        assertEquals(int(1), result9)
        assertEquals(int(8), result10)
        assertEquals(apair(int(1), int(2)), result11)
        assertEquals(int(1), result12)
        assertEquals(int(2), result13)
        assertEquals(auint, result14)
        assertEquals(auint, result15)
        assertEquals(int(0), result16)
    }


}