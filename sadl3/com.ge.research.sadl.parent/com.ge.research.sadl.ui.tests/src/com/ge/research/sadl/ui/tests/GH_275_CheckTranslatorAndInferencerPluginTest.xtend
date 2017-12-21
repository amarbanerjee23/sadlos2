/************************************************************************
 * Copyright © 2007-2017 - General Electric Company, All Rights Reserved
 * 
 * Project: SADL
 * 
 * Description: The Semantic Application Design Language (SADL) is a
 * language for building semantic models and expressing rules that
 * capture additional domain knowledge. The SADL-IDE (integrated
 * development environment) is a set of Eclipse plug-ins that
 * support the editing and testing of semantic models using the
 * SADL language.
 * 
 * This software is distributed "AS-IS" without ANY WARRANTIES
 * and licensed under the Eclipse Public License - v 1.0
 * which is available at http://www.eclipse.org/org/documents/epl-v10.php
 * 
 ***********************************************************************/
package com.ge.research.sadl.ui.tests

import java.util.Arrays
import org.junit.Test

import static com.ge.research.sadl.ui.tests.GeneratedOutputFormat.*

/**
 * Test that demonstrate how to make assertions on the generated translator outputs, plus runs the inferencer too.
 * 
 * @author akos.kitta
 */
class GH_275_CheckTranslatorAndInferencerPluginTest extends AbstractSadlPlatformTest {

	static val SHAPES = '''
		uri "http://sadl.org/Shapes.sadl" alias Shapes.
		
		Shape is a class described by area with values of type float.
		
		comment is a type of annotation.
		
		Circle is a type of Shape, described by radius with values of type float.
		
		MyCircle is a Circle with radius 3.
		
		Rule AreaOfCircle:
		  if c is a Circle
		  then area of c is radius of c ^ 2 * PI.
		
		AreaOfCircle has comment "ho".
		
		Ask Q1: area.
		
		Ask Q1.
		
		// Ask: x is a ^Rule.
		
		// Ask: select s,p,v where s has p v.
		// Ask: select s,p,v where s has p v.
		
		// Ask: select s p v where s has p v.
	''';

	static val POLYGONS = '''
		uri "http://sadl.org/Polygons.sadl" alias Polygons.
		
		import "http://sadl.org/Shapes.sadl".
		
		Rectangle is a type of Shape, described by height with values of type float,
		  described by width with values of type float.
		
		Polygons:area (note "URI is 'http://sadl.org/Polygons.sadl#area'") is a type of Shapes:area.
		
		Rule AreaOfRectangle
		  given x is any Rectangle
		  then area of x = height of x * width of x.
	''';

	static val TEST = '''
		uri "http://sadl.org/Test.sadl" alias Test.
		
		import "http://sadl.org/Polygons.sadl".
		
		MyRect is a Rectangle with height 2, with width 4.
		
		Ask Q1: area.
		
		Ask Q1.
		
		// Ask: x is a ^Rule.
	''';

	@Test
	def void checkTranslatorOutput() {
		createFile('Shapes.sadl', SHAPES);
		createFile('Polygons.sadl', POLYGONS);
		createFile('Test.sadl', TEST);
		assertNoErrorsInWorkspace;
		assertGeneratedOutputFor('Shapes.sadl', RULES) [
			assertEqualsIgnoreEOL('''
				# Jena Rules file generated by SADL IDE -- Do not edit! Edit the SADL model and regenerate.
				#  Created from SADL model 'http://sadl.org/Shapes.sadl'
				
				@prefix Shapes: <http://sadl.org/Shapes.sadl#>
				
				[AreaOfCircle: (?c rdf:type http://sadl.org/Shapes.sadl#Circle), (?c http://sadl.org/Shapes.sadl#radius ?v0), pow(?v0, 2, ?v1), product(?v1, 3.141592653589793, ?v2) -> (?c http://sadl.org/Shapes.sadl#area ?v2)]
			''', it);
		];
		assertGeneratedOutputFor('Polygons.sadl', RULES) [
			assertEqualsIgnoreEOL('''
				# Jena Rules file generated by SADL IDE -- Do not edit! Edit the SADL model and regenerate.
				#  Created from SADL model 'http://sadl.org/Polygons.sadl'
				
				@prefix Shapes: <http://sadl.org/Shapes.sadl#>
				@prefix Polygons: <http://sadl.org/Polygons.sadl#>
				
				[AreaOfRectangle: (?x rdf:type http://sadl.org/Polygons.sadl#Rectangle), (?x http://sadl.org/Polygons.sadl#height ?v0), (?x http://sadl.org/Polygons.sadl#width ?v1), product(?v0, ?v1, ?v2) -> (?x http://sadl.org/Shapes.sadl#area ?v2)]
			''', it);
		];
	}

	@Test
	def void checkInferencer() {
		createFile('Shapes.sadl', SHAPES);
		createFile('Polygons.sadl', POLYGONS);
		createFile('Test.sadl', TEST);
		assertNoErrorsInWorkspace;
		assertInferencer('Test.sadl') [
			// TODO do something with the SADL commands after running the inferencer.
			println(Arrays.toString(it));
		];
		assertNamedQuery('Test.sadl', 'Q1') [
			// TODO do something with the SADL commands after running the named query.
			println(Arrays.toString(it));
		];
	}

}
