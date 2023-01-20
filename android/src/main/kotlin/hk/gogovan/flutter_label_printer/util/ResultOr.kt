package hk.gogovan.flutter_label_printer.util

/**
 * Stores either an item or an error.
 */
class ResultOr<T> private constructor(val value: T?, val error: Exception?) {
    constructor(value: T) : this(value, null)

    constructor(error: Exception) : this(null, error)

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as ResultOr<*>

        if (value != other.value) return false
        if (error != other.error) return false

        return true
    }

    override fun hashCode(): Int {
        var result = value?.hashCode() ?: 0
        result = 31 * result + (error?.hashCode() ?: 0)
        return result
    }

    override fun toString(): String {
        return "ResultOr(value=$value, error=$error)"
    }


}
