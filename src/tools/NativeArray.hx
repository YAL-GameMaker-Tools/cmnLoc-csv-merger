package tools;

class NativeArray {
	public static inline function find<T>(arr:Array<T>, filter:T->Bool):Null<T> {
		return (cast arr).find(filter);
	}
}