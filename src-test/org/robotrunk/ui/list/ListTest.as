/*
 * Copyright (c) 2012 Tobias Goeschel.
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

package org.robotrunk.ui.list {

	import flash.display.DisplayObject;
	import flash.text.StyleSheet;

	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;
	import org.fluint.uiImpersonation.UIImpersonator;
	import org.robotrunk.ui.core.StyleMap;
	import org.robotrunk.ui.core.event.ViewEvent;
	import org.robotrunk.ui.list.api.List;
	import org.robotrunk.ui.list.api.ListCell;
	import org.robotrunk.ui.list.impl.ListImpl;
	import org.robotrunk.ui.list.impl.SimpleCellImpl;
	import org.robotrunk.ui.list.impl.SimpleListCellRenderer;

	public class ListTest {
		private var list:List;

		private var styleMap:StyleMap;
		private var styleSheet:StyleSheet;

		[Before]
		public function setUp():void {

			styleMap = new StyleMap();
			styleSheet = new StyleSheet();
			styleMap.styleSheet = styleSheet;
			list = new ListImpl( styleMap );
		}

		[Test]
		public function holdsListDefaultCellRenderer():void {
			assertNotNull( list.renderers );
			assertNotNull( list.renderers.default );
		}

		[Test]
		public function acceptsNewRenderers():void {
			list.addRenderer( "another", new SimpleListCellRenderer( SimpleCellImpl, styleSheet ) );
			assertNotNull( list.renderers.another );
		}

		[Test]
		public function acceptsAnArrayCollectionAsDataProvider():void {
			var data:ArrayCollection = new ArrayCollection();
			list.dataProvider = data;
			assertEquals( data, list.dataProvider );
		}

		[Test]
		public function acceptsAnArrayProvidingTheColumnNames():void {
			var structure:Array = ["name", "value"];
			list.structure = structure;
			assertEquals( structure, list.structure );
		}

		[Test(async, ui)]
		public function createsRowsAndCells():void {
			setUpForRendering();
			list.addEventListener( ViewEvent.RENDER_COMPLETE,
								   Async.asyncHandler( this, onCreatesRowsAndCellsRenderComplete, 500 ) );
			renderList();
		}

		private function onCreatesRowsAndCellsRenderComplete( ev:ViewEvent, ...rest ):void {
			assertEquals( 2, list.rows.length );
			verifyRow( 0, "someName", "someValue" );
			verifyRow( 1, "anotherName", "anotherValue" );
		}

		[Test(async, ui)]
		public function cellsInSameRowHaveTheSameHeight():void {
			setUpForRendering();
			list.addEventListener( ViewEvent.RENDER_COMPLETE,
								   Async.asyncHandler( this, onSameHeightRenderComplete, 500 ) );
			renderList();
		}

		private function onSameHeightRenderComplete( ev:ViewEvent, ...rest ):void {
			for each( var row:Array in list.rows ) {
				var hei:Number = 0;
				for each ( var cell:ListCell in row ) {
					if( hei>0 ) {
						assertEquals( hei, cell.height );
					} else {
						hei = cell.height;
					}
				}

			}
		}

		[Test(async, ui)]
		public function cellsInSameColumnHaveTheSameWidth():void {
			setUpForRendering();
			list.addEventListener( ViewEvent.RENDER_COMPLETE,
								   Async.asyncHandler( this, onSameWidthRenderComplete, 500 ) );
			renderList();
		}

		private function onSameWidthRenderComplete( ev:ViewEvent, ...rest ):void {
			var widths:Object = {};
			for each( var row:Array in list.rows ) {
				for each ( var cell:ListCell in row ) {
					assertTrue( cell.width>0 );
					if( widths[cell.property] ) {
						assertEquals( widths[cell.property], cell.width );
					} else {
						widths[cell.property] = cell.width;
					}
				}
			}
		}

		[Test(async, ui)]
		public function cellsInSameRowHaveTheSameY():void {
			setUpForRendering();
			list.addEventListener( ViewEvent.RENDER_COMPLETE, Async.asyncHandler( this, onSameYRenderComplete, 500 ) );
			renderList();
		}

		private function onSameYRenderComplete( ev:ViewEvent, ...rest ):void {
			var ys:Object = {};
			for each( var row:Array in list.rows ) {
				for each ( var cell:ListCell in row ) {
					if( ys[cell.property] ) {
						assertEquals( ys[cell.property], cell.y );
					} else {
						ys[cell.property] = cell.y;
					}
				}
			}
		}

		[Test(async, ui)]
		public function cellsInSameColumnHaveTheSameX():void {
			setUpForRendering();
			list.addEventListener( ViewEvent.RENDER_COMPLETE, Async.asyncHandler( this, onSameXRenderComplete, 500 ) );
			renderList();
		}

		private function onSameXRenderComplete( ev:ViewEvent, ...rest ):void {
			var xs:Object = {};
			for each( var row:Array in list.rows ) {
				for each ( var cell:ListCell in row ) {
					if( xs[cell.property] ) {
						assertEquals( xs[cell.property], cell.x );
					} else {
						xs[cell.property] = cell.x;
					}
				}
			}
		}

		private function setUpForRendering():void {
			var data:ArrayCollection = new ArrayCollection();
			data.addItem( {name: "someName", value: "someValue"} );
			data.addItem( {name: "anotherName", value: "anotherValue"} );
			list.dataProvider = data;
			list.structure = ["name", "value"];
		}

		private function renderList():void {
			list.render();
			var component:UIComponent = new UIComponent();
			component.addChild( list as DisplayObject );
			UIImpersonator.addChild( component );
		}

		private function verifyRow( index:int, name:String, value:String ):void {
			var row:Array = list.rows.getItemAt( index ) as Array;
			assertNotNull( row );

			assertEquals( "name", row[0].property );
			assertEquals( name, row[0].value );

			assertEquals( "value", row[1].property );
			assertEquals( value, row[1].value );
		}

		[Test]
		public function headerTitlesAreSuppliedAsAnArray():void {
			var header:Array = ["<text><p><span class=\"list_header\">Name</p></text>",
								"<text><p><span class=\"list_header\">Value</p></text>"];

			list.header = header;
			assertEquals( header, list.header );
		}

		[Test]
		public function cleansUpNicely():void {
			setUpForRendering();
			list.destroy();
			assertNull( list.renderers );
			assertNull( list.dataProvider );
			assertNull( list.rows );
			assertNull( list.structure );
			assertNull( list.header );
			assertNull( list.styleMap );
		}

		[After]
		public function tearDown():void {
			list.destroy();
			list = null;
			styleMap.destroy();
			styleMap = null;
			styleSheet = null;
		}
	}
}