package tools;

import js.html.SelectElement;
import js.html.Node;
import haxe.Rest;
import js.html.Document;
import haxe.extern.EitherType;
import js.html.Element;
import js.Browser.document;

class HtmlTools {
	private static inline function asElement(el:EitherType<Document, Element>):Element {
		return cast el;
	}
	
	public static inline function querySelectorEls(el:EitherType<Document, Element>, selectors:String):ElementList {
		return cast asElement(el).querySelectorAll(selectors);
	}
	public static inline function querySelectorAllAuto<T:Element>(el:EitherType<Document, Element>, selectors:String, ?c:Class<T>):ElementListOf<T> {
		return cast asElement(el).querySelectorAll(selectors);
	}
	public static inline function querySelectorAuto<T:Element>(
		el:EitherType<Document, Element>, selectors:String, ?c:Class<T>
	):T {
		return cast asElement(el).querySelector(selectors);
	}
	public static inline function appendMixed(el:Element, values:Rest<EitherType<String, Node>>) {
		for (item in values) {
			el.append(item);
		}
	}
}
extern class ElementList implements ArrayAccess<Element> {
	public var length(default, never):Int;
	public function item(index:Int):Element;
}
extern class ElementListOf<T:Element> implements ArrayAccess<T> {
	public var length(default, never):Int;
	public function item(index:Int):T;
}