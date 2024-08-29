@file:Suppress("UNCHECKED_CAST")
package org.example



interface MUPL<out T>

data class vaar<T>(val string: T): MUPL<T>
data class int<T>(val num: T): MUPL<T>
data class add<T>(val e1: MUPL<T>, val e2: MUPL<T>): MUPL<T>
data class ifgreater<T>(val e1: MUPL<T>, val e2: MUPL<T>, val e3: MUPL<T>, val e4: MUPL<T>): MUPL<T>
data class func<T>(val nameopt: T, val formal: T, val body: MUPL<T>): MUPL<T>
data class call<T>(val funexp: MUPL<T>, val actual: MUPL<T>): MUPL<T>
data class mlet<T>(val vaar: T, val e: MUPL<T>, val body: MUPL<T>): MUPL<T>
data class apair<T>(val e1: MUPL<T>, val e2: MUPL<T>): MUPL<T>
data class fst<T>(val e: MUPL<T>): MUPL<T>
data class snd<T>(val e: MUPL<T>): MUPL<T>
object auint: MUPL<Nothing>
data class isaunit<T>(val e: MUPL<T>): MUPL<T>
data class closure<T>(val env: List<Pair<String, MUPL<T>>>, val fuun: MUPL<T>): MUPL<T>


fun <T>kotlinListToMuplList(lst: List<MUPL<T>>): MUPL<T> {
    return if (lst.isEmpty()) {
        auint
    } else {
        apair(lst.first(), kotlinListToMuplList(lst.drop(1)))
    }
}


fun <T>muplListToKotlinList(lst: MUPL<T>): List<MUPL<T>> {
    return when (lst) {
        is auint -> listOf()
        is apair -> listOf(lst.e1) + muplListToKotlinList(lst.e2)
        else     -> error("Expected an apair, but got $lst")
    }
}


// lookup a variable in an environment
fun <T> envlookup(env: List<Pair<String, MUPL<T>>>, str: String): MUPL<T> {
    // Check if the environment list is empty
    if (env.isEmpty()) {
        throw IllegalArgumentException("Unbound variable: $str")
    }

    val firstPair = env.first()
    val (first, rest) = firstPair

    return if (first == str) {
        rest
    } else {
        envlookup(env.drop(1), str)
    }
}


fun <T> evalUnderEnv(e: MUPL<T>, env: List<Pair<String, MUPL<T>>> = emptyList()): MUPL<T> {
    return when (e) {
        is vaar      -> envlookup(env, e.string as String)
        is auint     -> e
        is int       -> e
        is func      -> closure(env, e)
        is closure   -> e

        is add       -> {
            val v1 = evalUnderEnv(e.e1, env) as? int
            val v2 = evalUnderEnv(e.e2, env) as? int

            return if (v1 != null && v2 != null) {
                int((v1.num as Int + v2.num as Int) as T)
            } else {
                error("MUPL addition applied to non-number")
            }
        }

        is mlet      -> {
            val v1 = evalUnderEnv(e.e, env)
            return evalUnderEnv(e.body, listOf(Pair(e.vaar as String, v1)) + env)
        }

        is ifgreater -> {
            val v1 = evalUnderEnv(e.e1, env) as? int
            val v2 = evalUnderEnv(e.e2, env) as? int

            if (v1 != null && v2 != null) {
                evalUnderEnv(if (v1.num as Int > v2.num as Int) e.e3 else e.e4, env)
            } else {
                error("MUPL ifgreater applied to non-number")
            }
        }

        is call      ->  {
            val v1 = evalUnderEnv(e.funexp, env) as? closure
            val v2 = evalUnderEnv(e.actual, env)

            return if (v1 != null) {
                val funClosure = v1.fuun as func
                val restEnv = if (funClosure.nameopt as String != "#f") listOf(Pair(funClosure.nameopt as String, v1)) + v1.env else v1.env
                val newEnv = listOf(Pair(funClosure.formal as String, v2)) + restEnv

                evalUnderEnv(funClosure.body, newEnv)
            } else {
                error("MUPL call applied to non-closure")
            }
        }

        is apair    -> {
            val v1 = evalUnderEnv(e.e1, env)
            val v2 = evalUnderEnv(e.e2, env)

            return apair(v1, v2)
        }

        is fst      -> {
            val pairValue = evalUnderEnv(e.e, env) as? apair

            return pairValue?.e1 ?: error("MUPL fst applied to non-pair")
        }

        is snd     -> {
            val pairValue = evalUnderEnv(e.e, env) as? apair

            return pairValue?.e2 ?: error("MUPL snd applied to non-pair")
        }

        is isaunit -> {
            val v = evalUnderEnv(e.e, env) as? auint

            return if (v != null) int(1 as T) else int(0 as T)
        }

        else -> error("bad MUPL expression: $e")

    }
}


fun <T> evalExp(e: MUPL<T>): MUPL<T> = evalUnderEnv(e)


fun <T> ifaunit(e1: MUPL<T>, e2: MUPL<T>, e3: MUPL<T>): MUPL<T> {
    return ifgreater(isaunit(e1), int(0 as T), e2, e3)
}


fun <T> mletStar(lstlst: List<Pair<String, MUPL<T>>>, e2: MUPL<T>): MUPL<T> {
    return if (lstlst.isEmpty()) {
        e2
    } else {
        val v = lstlst.first()
        mlet(v.first as T, v.second, mletStar(lstlst.drop(1), e2))
    }
}


fun <T> ifeq(e1: MUPL<T>, e2: MUPL<T>, e3: MUPL<T>, e4: MUPL<T>): MUPL<T> {
    return mletStar(listOf(Pair("_x", e1), Pair("_y", e2)),
        ifgreater(vaar("_x" as T), vaar("_y" as T), e4, ifgreater(vaar("_y" as T), vaar("_x" as T), e4, e3)))
}


val muplMap by lazy {
    func("fun", "x", func("funLst", "lst",
        ifeq(isaunit(vaar("lst")), int(1), auint,
            apair(call(vaar("x"), fst(vaar("lst"))),
                call(vaar("funLst"), snd(vaar("lst")))))))
}


val muplMapAddN by lazy {
    mlet("map", muplMap,
        func("muplFunInt", "i",
            func("muplFunList", "mplInt",
                call(call(vaar("map"),
                    func("addI", "x", add(vaar("x"), vaar("i")))),
                    vaar("mplInt")))))
}


//  a recursive(?) 1-argument function
data class funChallenge<T>(val nameopt: T, val formal: T, val body: MUPL<T>, val freevars: Set<T>): MUPL<T>


fun <T> computeFreeVars(e: MUPL<T>): MUPL<T> {
    data class res<T>(val e: MUPL<T>, val fvs: Set<T>): MUPL<T>

    fun f(e: MUPL<T>): res<T> {
        return when (e) {
            is vaar      -> res(e, setOf(e.string))

            is int       -> res(e, emptySet())

            is add       -> {
                val r1: res<T> = f(e.e1)
                val r2: res<T> = f(e.e2)

                return res(add(r1.e, r2.e), r1.fvs.union(r2.fvs))
            }

            is ifgreater -> {
                val r1: res<T> = f(e.e1)
                val r2: res<T> = f(e.e2)
                val r3: res<T> = f(e.e3)
                val r4: res<T> = f(e.e4)

                return res(ifgreater(r1.e, r2.e, r3.e, r4.e),
                    r1.fvs.union(r2.fvs).union(r3.fvs).union(r4.fvs))
            }

            is func -> {
                val r = f(e.body)
                var fsv = r.fvs.subtract(setOf(e.formal))
                if (e.nameopt != "#f") {
                    fsv = fsv.subtract(setOf(e.nameopt))
                }
                res(funChallenge(e.nameopt, e.formal, r.e, fsv), fsv)
            }

            is call      -> {
                val r1: res<T> = f(e.funexp)
                val r2: res<T> = f(e.actual)

                return res(call(r1.e, r2.e), r1.fvs.union(r2.fvs))
            }

            is mlet      -> {
                val r1: res<T> = f(e.e)
                val r2: res<T> = f(e.body)

                return res(mlet(e.vaar, r1.e, r2.e),
                    r1.fvs.union(r2.fvs.subtract(setOf(e.vaar))))
            }

            is apair    -> {
                val r1: res<T> = f(e.e1)
                val r2: res<T> = f(e.e2)

                return res(apair(r1.e, r2.e),
                    r1.fvs.union(r2.fvs))
            }

            is fst      -> {
                val r: res<T> = f(e.e)

                return res(fst(r.e), r.fvs)
            }

            is snd      -> {
                val r: res<T> = f(e.e)

                return res(snd(r.e), r.fvs)
            }

            is auint    -> res(e, emptySet())

            is isaunit  -> {
                val r = f(e.e)

                return res(isaunit(r.e), r.fvs)
            }

            else         -> error("bad MUPL expression: $e")
        }

    }

    return f(e).e
}


fun <T> evalUnderEvnC(e: MUPL<T>, env: List<Pair<String, MUPL<T>>>): MUPL<T> {
    return when (e) {
        is int          -> e

        is vaar         -> envlookup(env, e.string as String)

        is funChallenge -> closure(e.freevars.map { s: T ->
            val newEnv = envlookup(env, s as String)
            Pair(s as String, newEnv)
        }, e)

        is closure      -> e

        is add          -> {
            val v1 = evalUnderEvnC(e.e1, env) as? int
            val v2 = evalUnderEvnC(e.e2, env) as? int

            return if (v1 != null && v2 != null) {
                int((v1.num as Int + v2.num as Int) as T)
            } else {
                error("MUPL addition applied to non-number")
            }
        }

        is call         -> {
            val funExp = evalUnderEvnC(e.funexp, env) as? closure
            val argVal = evalUnderEvnC(e.actual, env)

            return if (funExp != null) {
                val extendedEnv = (funExp.env + Pair((funExp.fuun as funChallenge).formal as String, argVal)).toMutableList()

                if (funExp.fuun.nameopt != "#f") {
                    extendedEnv.add(Pair(funExp.fuun.nameopt as String, funExp))
                }

                evalUnderEvnC(funExp.fuun.body, extendedEnv)
            } else {
                error("call should be applied to a function closure")
            }
        }

        is ifgreater    -> {
            val v1 = evalUnderEvnC(e.e1, env) as? int
            val v2 = evalUnderEvnC(e.e2, env) as? int


            return if (v1 != null && v2 != null) {
                evalUnderEvnC(if (v1.num as Int > v2.num as Int) e.e3 else e.e4, env)
            } else {
                error("MUPL ifgreater applied to non-number")
            }
        }

        is mlet         -> {
            val v1: MUPL<T> = evalUnderEvnC(e.e, env)

            return evalUnderEvnC(e.body, listOf(Pair(e.vaar as String, v1)) + env)
        }

        is apair        -> {
            val v1 = evalUnderEvnC(e.e1, env)
            val v2 = evalUnderEvnC(e.e2, env)

            return apair(v1, v2)
        }

        is fst          -> {
            val pairVal = evalUnderEvnC(e.e, env) as? apair
            return pairVal?.e1 ?: error("fst applied to non-pair")
        }

        is snd          -> {
            val pairVal = evalUnderEvnC(e.e, env) as? apair
            return pairVal?.e2 ?: error("snd applied to non-pair")
        }

        is auint        -> e

        is isaunit      -> {
            val evalExp = evalUnderEvnC(e.e, env)
            return if (evalExp is auint) auint else int(0 as T)
        }

        else -> error("bad MUPL expression $e")
    }
}


fun <T> evalExpC(e: MUPL<T>): MUPL<T> = evalUnderEvnC(computeFreeVars(e), emptyList())