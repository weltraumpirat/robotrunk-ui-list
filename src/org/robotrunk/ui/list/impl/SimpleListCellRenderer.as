/*
 * Copyright (c) 2013 Tobias Goeschel.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package org.robotrunk.ui.list.impl {
	import flash.text.StyleSheet;

	import org.robotrunk.ui.list.api.ListCell;

	public class SimpleListCellRenderer extends ListCellRenderer {
		private var _styleSheet:StyleSheet;

		public function SimpleListCellRenderer( clazz:Class, styleSheet:StyleSheet ) {
			super( _clazz );
			_styleSheet = styleSheet;
		}

		override public function render( property:String, row:* ):ListCell {
			var item:ListCell = new _clazz( _styleSheet );
			item.property = property;
			item.data = row;
			return item;
		}

		override public function destroy():void {
			_styleSheet = null;
			super.destroy();
		}
	}
}