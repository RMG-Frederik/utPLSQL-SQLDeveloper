/*
 * Copyright 2018 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.utplsql.sqldev.preferences.tests

import org.junit.Assert
import org.junit.Test
import org.utplsql.sqldev.parser.UtplsqlParser

class UtplsqlParserTest {

	@Test
	def testPackage() {
		val plsql = '''
			PROMPT
			PROMPT Install utPLSQL test package
			PROMPT
			
			/*
			 * some comment
			 */
			-- %suite
			-- %rollback(manual)
			CREATE OR REPLACE PACKAGE pkg IS
			   -- %test
			   PROCEDURE p (in_p1 INTEGER);
			   FUNCTION f (in_p1 INTEGER) RETURN INTEGER;
			END pkg;
			/
			SHOW ERRORS
			
			CREATE OR REPLACE PACKAGE BODY "SCOTT"."PKG" IS
			   PROCEDURE "P" (in_p1 INTEGER) IS
			   BEGIN
			      NULL;
			   END p;
			
			   /* comment 1 */
			   -- comment 2
			   /* comment 3 */
			   -- comment 4
			
			   FUNCTION "F" (in_p1 INTEGER) RETURN INTEGER IS
			   BEGIN
			      RETURN 1;
			   END f;
			END pkg;
			/
			SHOW ERRORS
		'''
		val parser = new UtplsqlParser(plsql)
		val objects = parser.getObjects
		Assert.assertEquals(2, objects.size)
		Assert.assertEquals("pkg", objects.get(0).name)
		Assert.assertEquals('''"SCOTT"."PKG"'''.toString, objects.get(1).name)
		Assert.assertTrue(objects.get(0).position < objects.get(1).position)
		val units = parser.getUnits
		Assert.assertEquals(4, units.size)
		Assert.assertEquals("p", units.get(0).name)
		Assert.assertEquals("f", units.get(1).name)
		Assert.assertEquals('''"P"'''.toString, units.get(2).name)
		Assert.assertEquals('''"F"'''.toString, units.get(3).name)
		Assert.assertTrue(units.get(0).position < units.get(1).position)
		Assert.assertTrue(units.get(1).position < units.get(2).position)
		Assert.assertTrue(units.get(2).position < units.get(3).position)
		Assert.assertEquals("", parser.getPathAt(0))
		Assert.assertEquals("", parser.getPathAt(3,6))
		Assert.assertEquals("pkg", parser.getPathAt(4,1))
		Assert.assertEquals("pkg.p", parser.getPathAt(10,33))
		Assert.assertEquals("pkg.f", parser.getPathAt(13,1))
		Assert.assertEquals("SCOTT.PKG.P", parser.getPathAt(19,1))
		Assert.assertEquals("SCOTT.PKG.P", parser.getPathAt(22,9))
		Assert.assertEquals("SCOTT.PKG.F", parser.getPathAt(22,10))
		Assert.assertEquals("SCOTT.PKG.F", parser.getPathAt(29,1))
	}	
}
