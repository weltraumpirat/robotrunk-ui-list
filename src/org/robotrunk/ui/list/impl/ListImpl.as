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

package org.robotrunk.ui.list.impl {
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;

	import mx.collections.ArrayCollection;

	import org.robotools.graphics.removeAll;
	import org.robotrunk.ui.core.StyleMap;
	import org.robotrunk.ui.core.event.ViewEvent;
	import org.robotrunk.ui.core.impl.UIComponentImpl;
	import org.robotrunk.ui.list.api.List;
	import org.robotrunk.ui.list.api.ListCell;

	public class ListImpl extends UIComponentImpl implements List {
		private var _renderers:Dictionary;
		private var _dataProvider:ArrayCollection;
		private var _structure:Array;
		private var _rows:ArrayCollection;
		private var _cells:ArrayCollection;
		private var _header:Array;
		private var _styleMap:StyleMap;
		private var _cellRenderCount:int = 0;
		private var _cellRenderedCount:int = 0;

		public function ListImpl( styleMap:StyleMap ) {
			_styleMap = styleMap;
			addRenderer( "default", new SimpleListCellRenderer( SimpleCellImpl, _styleMap.styleSheet ) );
		}

		public function render():void {
			if( _cells != null ) {
				clearAllCells();
			}
			_cells = new ArrayCollection();
			_rows = new ArrayCollection();
			for each( var row:Object in dataProvider ) {
				_rows.addItem( createRow( row ) );
			}
			for each( var cell:ListCell in _cells ) {
				addChild( cell as DisplayObject );
			}
		}

		private function clearAllCells():void {
			removeAll( this );
			for each( var cell:ListCell in _cells ) {
				cell.destroy();
			}
			_cells = null;
			_rows = null;
			_cellRenderCount = 0;
			_cellRenderedCount = 0;
		}

		private function createRow( row:Object ):Array {
			var cells:Array = [];
			for each( var name:String in structure ) {
				var cell:ListCell = initCell( name, row );
				if( cell != null ) {
					cells[cells.length] = cell;
					_cells.addItem( cell );
				}
			}
			return cells;
		}

		private function initCell( name:String, row:Object ):ListCell {
			var cell:ListCell = createCell( name, row );
			cell.addEventListener( ViewEvent.RENDER, onCellRender );
			cell.addEventListener( ViewEvent.RENDER_COMPLETE, onCellRenderComplete );
			return cell;
		}

		private function onCellRender( ev:ViewEvent ):void {
			if( ev.currentTarget is ListCell ) {
				ev.currentTarget.removeEventListener( ViewEvent.RENDER, onCellRender );
				if( ++_cellRenderCount == 1 ) {
					dispatchEvent( new ViewEvent( ViewEvent.RENDER ) );
				}
			}
		}

		private function onCellRenderComplete( ev:ViewEvent ):void {
			if( ev.currentTarget is ListCell ) {
				ev.currentTarget.removeEventListener( ViewEvent.RENDER_COMPLETE, onCellRenderComplete );
				if( ++_cellRenderedCount == _cells.length ) {
					normalizeCellSize();
					setTimeout( function ():void {
						dispatchEvent( new ViewEvent( ViewEvent.RENDER_COMPLETE ) );
					}, 100 );
				}
			}
		}

		private function normalizeCellSize():void {
			adjustColumnSizes();
			adjustRowSizes();
		}

		private function adjustColumnSizes():void {
			setCellsToColumnWidth( getMaximumColumnWidths() );
		}

		private function setCellsToColumnWidth( widths:Object ):void {
			for each( var row:Array in rows ) {
				setRowCellWidths( row, widths );
			}

		}

		private function setRowCellWidths( row:Array, widths:Object ):void {
			var _x:int = 0;
			for each ( var cell:ListCell in row ) {
				var wid:Number = widths[cell.property];
				cell.x = _x;
				cell.width = wid;
				_x += wid+style.offset;
			}
		}

		private function getMaximumColumnWidths():Object {
			var widths:Object = {};
			for each( var row:Array in rows ) {
				for each( var cell:ListCell in row ) {
					widths[cell.property] = getMaximumColumnWidth( cell, widths[cell.property] );
				}
			}
			return widths;
		}

		private function getMaximumColumnWidth( cell:ListCell, wid:Number ):Number {
			wid = isNaN( wid ) ? 0 : wid;
			return cell.width>wid ? cell.width : wid;
		}

		private function adjustRowSizes():void {
			var _y:int = 0;
			for each( var row:Array in rows ) {
				var hei:Number = getMaximumRowHeight( row );
				setCellsToRowHeight( row, hei );
				setCellsToRowY( row, _y );
				_y += hei+style.offset;
			}
		}

		private function setCellsToRowY( row:Array, _y:int ):void {
			for each( var cell:ListCell in row ) {
				cell.y = _y;
			}
		}

		private function setCellsToRowHeight( row:Array, hei:Number ):void {
			for each( var cell:ListCell in row ) {
				cell.height = hei;
			}
		}

		private function getMaximumRowHeight( row:Array ):Number {
			var hei:Number = 0;
			for each( var cell:ListCell in row ) {
				hei = cell.height>hei ? cell.height : hei;
			}
			return hei;
		}

		private function createCell( name:String, row:* ):ListCell {
			var renderer:ListCellRenderer = _renderers[name];
			return renderer ? renderer.render( name, row ) : _renderers["default"].render( name, row );
		}

		override public function destroy():void {
			destroyRows();
			_rows = null;
			_renderers = null;
			_dataProvider = null;
			_structure = null;
			_styleMap = null;
			_header = null;
			super.destroy();
		}

		private function destroyRows():void {
			for each( var row:Array in rows ) {
				for each( var cell:ListCell in row ) {
					cell.destroy();
				}
			}
		}

		public function addRenderer( identifier:String, listCellRenderer:ListCellRenderer ):void {
			_renderers ||= new Dictionary();
			_renderers[identifier] = listCellRenderer;
		}

		public function get renderers():Dictionary {
			return _renderers;
		}

		public function get dataProvider():ArrayCollection {
			return _dataProvider;
		}

		public function set dataProvider( dataProvider:ArrayCollection ):void {
			_dataProvider = dataProvider;
		}

		public function get structure():Array {
			return _structure;
		}

		public function set structure( structure:Array ):void {
			_structure = structure;
		}

		public function get rows():ArrayCollection {
			return _rows;
		}

		public function set header( header:Array ):void {
			_header = header;
		}

		public function get header():Array {
			return _header;
		}

		public function get styleMap():StyleMap {
			return _styleMap;
		}

		override public function get width():Number {
			return super.width>0 ? super.width : parent != null ? parent.getBounds( this ).width : 0;
		}

		override public function get height():Number {
			return super.height>0 ? super.height : parent != null ? parent.getBounds( this ).height : 0;
		}
	}
}