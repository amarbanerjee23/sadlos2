/*
 * © 2014-2017 General Electric Company – All Rights Reserved
 *
 * This software and any accompanying data and documentation are CONFIDENTIAL 
 * INFORMATION of the General Electric Company (“GE”) and may contain trade secrets 
 * and other proprietary information.  It is intended for use solely by GE and authorized 
 * personnel.
 */
package com.ge.research.sadl.tests.model

import com.ge.research.sadl.tests.SADLInjectorProvider
import com.google.inject.Inject
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.Ignore
import static org.junit.Assert.*
import org.eclipse.emf.ecore.resource.Resource
import com.hp.hpl.jena.ontology.OntModel
import java.util.List
import com.ge.research.sadl.model.gp.Rule
import com.ge.research.sadl.model.gp.SadlCommand
import org.eclipse.xtext.validation.Issue
import org.eclipse.xtext.testing.util.ParseHelper
import com.ge.research.sadl.sADL.SadlModel
import com.ge.research.sadl.jena.JenaBasedSadlModelProcessor
import com.google.inject.Provider
import org.eclipse.xtext.preferences.IPreferenceValuesProvider
import org.eclipse.xtext.util.CancelIndicator
import com.ge.research.sadl.processing.IModelProcessor.ProcessorContext
import org.eclipse.xtext.validation.CheckMode
import com.ge.research.sadl.processing.ValidationAcceptorImpl

@RunWith(XtextRunner)
@InjectWith(SADLInjectorProvider)
class ExtendedIFTest extends AbstractProcessorTest {
		
	@Inject ParseHelper<SadlModel> parser
	@Inject ValidationTestHelper validationTestHelper
	@Inject Provider<JenaBasedSadlModelProcessor> processorProvider
	@Inject IPreferenceValuesProvider preferenceProvider
	
	@Test
	def void testCRule_01() {
		val sadlModel = '''
			uri "http://sadl.org/rulevars.sadl" alias rulevars.
						
			Person is a class.
			teaches describes Person with values of type Person.
			knows describes Person with values of type Person.
			A relationship of Person to Person is acquaintance. 
			
			Rule R1 if x is a Person and x has teaches y then x has knows y.
			 
			Rule R2 if x is a Person and x has teaches y then x has acquaintance y. 
			
			Rule R3 if x is a Person and x teaches y then x knows y.
			
			//Rule R4: if a Person knows a second Person then the second Person knows the first Person.
			Rule R4b: if a Person has knows a second Person then the second Person has knows the first Person.
			
			Rule R5: if x is a Person and knows of x is y then knows of y is x.
			Rule R5b: if x is a Person and x knows y then y knows x.
			
			Rule R6: if x is a Person and y teaches x then x knows y.
		'''.assertValidatesTo [ jenaModel, rules, cmds, issues |
 			assertNotNull(jenaModel)
	 		if (issues !== null) {
				for (issue:issues) {
					print(issue.message)
				}
			}
			if (rules != null) {
				for (rule:rules) {
					print(rule.toString + "\n")
				}
			}
 			assertTrue(issues.size == 0)
 			assertTrue(rules.size == 7)
 			assertTrue(processorProvider.get.compareTranslations(rules.get(0).toString(),"Rule R1:  if and(rdf(x, rdf:type, rulevars:Person), rdf(x, rulevars:teaches, y)) then rdf(x, rulevars:knows, y)."))
 			assertTrue(processorProvider.get.compareTranslations(rules.get(1).toString(),"Rule R2:  if and(rdf(x, rdf:type, rulevars:Person), rdf(x, rulevars:teaches, y)) then rdf(x, rulevars:acquaintance, y)."))
 			assertTrue(processorProvider.get.compareTranslations(rules.get(2).toString(),"Rule R3:  if and(rdf(x, rdf:type, rulevars:Person), rdf(x, rulevars:teaches, y)) then rdf(x, rulevars:knows, y)."))
  			assertTrue(processorProvider.get.compareTranslations(rules.get(3).toString(),"Rule R4b:  if and(rdf(v0, rdf:type, rulevars:Person), and(rdf(v0, rulevars:knows, v1), and(rdf(v1, rdf:type, rulevars:Person), !=(v0,v1)))) then rdf(v1, rulevars:knows, v0)."))
 			assertTrue(processorProvider.get.compareTranslations(rules.get(4).toString(),"Rule R5:  if and(rdf(x, rdf:type, rulevars:Person), rdf(x, rulevars:knows, y)) then rdf(y, rulevars:knows, x)."))
 			assertTrue(processorProvider.get.compareTranslations(rules.get(5).toString(),"Rule R5b:  if and(rdf(x, rdf:type, rulevars:Person), rdf(x, rulevars:knows, y)) then rdf(y, rulevars:knows, x)."))
 			assertTrue(processorProvider.get.compareTranslations(rules.get(6).toString(),"Rule R6:  if and(rdf(x, rdf:type, rulevars:Person), rdf(y, rulevars:teaches, x)) then rdf(x, rulevars:knows, y)."))
		]
	}
	
	@Test
	def void testCRule_02() {
		val sadlModel = '''
			uri "http://sadl.org/rulevars.sadl" alias rulevars.
						
			Person is a class.
			teaches describes Person with values of type Person.
			knows describes Person with values of type Person.
			A relationship of Person to Person is acquaintance. 
			
			Rule R1 if a Person has teaches another Person then the Person has knows the other Person.
			 
«««			Rule R2 if a Person teaches a second Person then the first Person has acquaintance the second Person. 
			
			//Rule R3: if a Person knows a second Person then the second Person knows the first Person.
			Rule R3b: if a Person has knows a second Person then the second Person has knows the first Person.
		'''.assertValidatesTo [ jenaModel, rules, cmds, issues |
 			assertNotNull(jenaModel)
	 		if (issues !== null) {
				for (issue:issues) {
					print(issue.message)
				}
			}
			if (rules != null) {
				for (rule:rules) {
					print(rule.toString + "\n")
				}
			}
 			assertTrue(issues.size == 0)
 			assertTrue(rules.size == 2)
 			assertTrue(processorProvider.get.compareTranslations(rules.get(0).toString(),"Rule R1:  if and(rdf(v0, rdf:type, rulevars:Person), and(rdf(v0, rulevars:teaches, v1), and(rdf(v1, rdf:type, rulevars:Person), !=(v0,v1)))) then rdf(v0, rulevars:knows, v1)."))
 			assertTrue(processorProvider.get.compareTranslations(rules.get(1).toString(),"Rule R3b:  if and(rdf(v2, rdf:type, rulevars:Person), and(rdf(v2, rulevars:knows, v3), and(rdf(v3, rdf:type, rulevars:Person), !=(v2,v3)))) then rdf(v3, rulevars:knows, v2)."))
		]
	}
	
	
	@Test
	def void testCRule_03() {
		val sadlModel = '''
			uri "http://sadl.org/model3.sadl" alias model3.
			 
			AdjacencyType is a class, must be one of {TANGENT, CONVEX}.
			
			AbstractSADLnx is a top-level class.
					
			AbstractEdge (alias "Edge") is a type of AbstractSADLnx,
				described by edgeAdjacencyType with a single value of type AdjacencyType.
				
			Intersection is a type of AbstractEdge.
			
			AbstractFace is a type of AbstractSADLnx,
				described by edge with values of type AbstractEdge, 
				described by adjacentFace with values of type AbstractFace.
				
			{Cylindrical, Blending} are types of AbstractFace.
			
			isFloorFace describes Cylindrical with a single value of type boolean. 
			concave describes Cylindrical with a single value of type boolean. 
			
			AbstractFeature is a type of AbstractSADLnx,
				described by featureFace with values of type AbstractFace,
				described by otherFace with values of type AbstractFace.
			
			PadFillet is a type of AbstractFeature,
				described by bottomFace with a single value of type AbstractFace,
				described by bottomEdge with a single value of type AbstractEdge.
				
			facesShareEndPoint describes AbstractFace with values of type AbstractFace.
			
			Rule findPadFillet1:
			if a Blending has edge a first Intersection with edgeAdjacencyType TANGENT and
				the Blending has edge a second Intersection with edgeAdjacencyType TANGENT and
				the second Intersection != the first Intersection and
				a first AbstractFace has edge the second Intersection and
				concave of the first AbstractFace is false and	
				isFloorFace of the first AbstractFace is false and	
				the first AbstractFace is a Cylindrical and 
				a second AbstractFace has edge the first Intersection and
				the first Blending != the second AbstractFace and
				the Blending has adjacentFace a third AbstractFace and
				the Blending has facesShareEndPoint the third AbstractFace and	
				not the first AbstractFace has facesShareEndPoint the second AbstractFace and	
				the second AbstractFace has edge an AbstractEdge with edgeAdjacencyType CONVEX and
				the AbstractEdge != the first Intersection
			then
				there exists a PadFillet with featureFace the Blending and
				the PadFillet has otherFace the second AbstractFace and
				the PadFillet has bottomFace the first AbstractFace and
				the PadFillet has bottomEdge the second Intersection and
				the PadFillet has otherFace "Pad Fillet".
		'''.assertValidatesTo [ jenaModel, rules, cmds, issues |
 			assertNotNull(jenaModel)
	 		if (issues !== null) {
				for (issue:issues) {
					print(issue.message)
				}
			}
			if (rules != null) {
				for (rule:rules) {
					print(rule.toString)
				}
			}
 			assertTrue(issues.size == 0)
 			assertTrue(rules.size == 1)
 			assertTrue(processorProvider.get.compareTranslations(rules.get(0).toString(),"Rule findPadFillet1:  if and(rdf(v0, rdf:type, model3:Blending), and(rdf(v0, model3:edge, v1), and(rdf(v1, rdf:type, model3:Intersection), and(rdf(v1, model3:edgeAdjacencyType, model3:TANGENT), and(rdf(v0, model3:edge, v2), and(rdf(v2, rdf:type, model3:Intersection), and(rdf(v2, model3:edgeAdjacencyType, model3:TANGENT), and(!=(v2,v1), and(rdf(v3, rdf:type, model3:AbstractFace), and(rdf(v3, model3:edge, v2), and(rdf(v3, model3:concave, false), and(rdf(v3, model3:isFloorFace, false), and(rdf(v3, rdf:type, model3:Cylindrical), and(rdf(v4, rdf:type, model3:AbstractFace), and(rdf(v4, model3:edge, v1), and(!=(v3,v4), and(!=(v0,v4), and(rdf(v0, model3:adjacentFace, v5), and(rdf(v5, rdf:type, model3:AbstractFace), and(!=(v4,v5), and(!=(v3,v5), and(rdf(v0, model3:facesShareEndPoint, v5), and(Not(rdf(v3, model3:facesShareEndPoint, v4)), and(rdf(v4, model3:edge, v6), and(rdf(v6, rdf:type, model3:AbstractEdge), and(rdf(v6, model3:edgeAdjacencyType, model3:CONVEX), !=(v6,v1))))))))))))))))))))))))))) then and(there exists(v7), and(rdf(v7, rdf:type, model3:PadFillet), and(rdf(v7, model3:featureFace, v0), and(rdf(v7, model3:otherFace, v4), and(rdf(v7, model3:bottomFace, v3), and(rdf(v7, model3:bottomEdge, v2), rdf(v7, model3:otherFace, \"Pad Fillet\")))))))."))
		]
	}
	
	@Test
	def void testCRule_04() {
		val sadlModel = '''
			 uri "http://sadl.org/genealogy.sadl" alias genealogy.
			 
			 Person is a class described by gender with values of type Gender,
			 	described by child with values of type Person.
			 	
			 Gender is a class, must be one of {Male, Female}.
			 
			 {Man, Woman, Parent, Mother, Father, Aunt, Uncle, Grandparent, Grandfather, Grandmother} are types of Person.
			 
			 sibling describes Person with values of type Person.
			 sibling is symmetrical .
			 aunt describes Person with values of type Person.
			 uncle describes Person with values of type Person.
			 grandchild describes Person with values of type Person.
			 son is a type of child.
			 daughter is a type of child.
			 grandson is a type of grandchild.
			 granddaughter is a type of grandchild.
			 cousin describes Person with values of type Person.
			 cousin is symmetrical .
			 
			 A Person is a Parent only if child has at least 1 value.
			 A Person is a Man only if gender always has value Male.
			 A Person is a Woman only if gender always has value Female.
			 A Person is a Mother only if child has at least 1 value and gender always has value Female.
			 A Person is a Father only if child has at least 1 value and gender always has value Male.
			 A Grandparent is a Grandmother only if gender always has value Female.
			 A Grandparent is a Grandfather only if gender always has value Male.
			 
			 Rule DaughterRule:
			 	if a Person has child a second Person and the second Person has gender Female
			 	then the Person has daughter the second Person.
			 	
			 Rule SonRule:
			 	if a Person has child another Person and the other Person has gender Male
			 	then the Person has son the other Person.
			 		
			 Rule SiblingRule: 
			 	if a Person has child a second Person and the Person has child a third Person
			 	then the second Person has sibling the third Person.
			 	
			 Rule GrandparentRule:
			 	if a Person has child a second Person and the second Person has child a third Person
			 	then the Person is a Grandparent and the Person has grandchild the third Person.
			 	
			 Rule GranddaughterRule:
			 	if a Person has grandchild another Person 
			 		and the other Person has gender Female
			 	then the Person has granddaughter the other Person. 	
			 	
			 Rule GrandsonRule:
			 	if a Person has grandchild another Person 
			 		and the other Person has gender Male
			 	then the Person has grandson the other Person. 	
			 	
			 Rule AuntRule:
			 	if a Person has sibling a second Person 
			 		and the second Person has gender Female
			 		and the Person has child a third Person
			 	then the second Person is an Aunt
			 		 and the third Person has aunt the second Person.
			 		 
			 Rule UncleRule:
			 	if a Person has sibling a second Person 
			 		and the second Person has gender Male
			 		and the Person has child a third Person
			 	then the second Person is an Uncle
			 		 and the third Person has uncle the second Person.
			 		 
			 Rule CousinRule:
			 	if a Person has sibling a second Person
			 		and the Person has child a third Person
			 		and the second Person has child a fourth Person
			 	then the third Person has cousin the fourth Person.
		'''.assertValidatesTo [ jenaModel, rules, cmds, issues |
 			assertNotNull(jenaModel)
	 		if (issues !== null) {
				for (issue:issues) {
					print(issue.message + "\n")
				}
			}
			if (rules != null) {
				for (rule:rules) {
					print(rule.toString + "\n")
				}
			}
		Assert.assertNotNull(issues)
 			assertTrue(issues.size == 0)
 			assertTrue(rules.size == 9)
 			assertTrue(processorProvider.get.compareTranslations(rules.get(0).toString(),"Rule DaughterRule:  if and(rdf(v0, rdf:type, genealogy:Person), and(rdf(v0, genealogy:child, v1), and(rdf(v1, rdf:type, genealogy:Person), and(!=(v0,v1), rdf(v1, genealogy:gender, genealogy:Female))))) then rdf(v0, genealogy:daughter, v1)."))
 			assertTrue(processorProvider.get.compareTranslations(rules.get(1).toString(),"Rule SonRule:  if and(rdf(v2, rdf:type, genealogy:Person), and(rdf(v2, genealogy:child, v3), and(rdf(v3, rdf:type, genealogy:Person), and(!=(v2,v3), rdf(v3, genealogy:gender, genealogy:Male))))) then rdf(v2, genealogy:son, v3)."))
 			assertTrue(processorProvider.get.compareTranslations(rules.get(2).toString(),"Rule SiblingRule:  if and(rdf(v4, rdf:type, genealogy:Person), and(rdf(v4, genealogy:child, v5), and(rdf(v5, rdf:type, genealogy:Person), and(!=(v4,v5), and(rdf(v4, genealogy:child, v6), and(rdf(v6, rdf:type, genealogy:Person), and(!=(v5,v6), !=(v4,v6)))))))) then rdf(v5, genealogy:sibling, v6)."))
  			assertTrue(processorProvider.get.compareTranslations(rules.get(3).toString(),"Rule GrandparentRule:  if and(rdf(v7, rdf:type, genealogy:Person), and(rdf(v7, genealogy:child, v8), and(rdf(v8, rdf:type, genealogy:Person), and(!=(v7,v8), and(rdf(v8, genealogy:child, v9), and(rdf(v9, rdf:type, genealogy:Person), and(!=(v8,v9), !=(v7,v9)))))))) then and(rdf(v7, rdf:type, genealogy:Grandparent), rdf(v7, genealogy:grandchild, v9))."))
 			assertTrue(processorProvider.get.compareTranslations(rules.get(4).toString(),"Rule GranddaughterRule:  if and(rdf(v10, rdf:type, genealogy:Person), and(rdf(v10, genealogy:grandchild, v11), and(rdf(v11, rdf:type, genealogy:Person), and(!=(v10,v11), rdf(v11, genealogy:gender, genealogy:Female))))) then rdf(v10, genealogy:granddaughter, v11)."))
			assertTrue(processorProvider.get.compareTranslations(rules.get(5).toString(),"Rule GrandsonRule:  if and(rdf(v12, rdf:type, genealogy:Person), and(rdf(v12, genealogy:grandchild, v13), and(rdf(v13, rdf:type, genealogy:Person), and(!=(v12,v13), rdf(v13, genealogy:gender, genealogy:Male))))) then rdf(v12, genealogy:grandson, v13)."))
			assertTrue(processorProvider.get.compareTranslations(rules.get(6).toString(),"Rule AuntRule:  if and(rdf(v14, rdf:type, genealogy:Person), and(rdf(v14, genealogy:sibling, v15), and(rdf(v15, rdf:type, genealogy:Person), and(!=(v14,v15), and(rdf(v15, genealogy:gender, genealogy:Female), and(rdf(v14, genealogy:child, v16), and(rdf(v16, rdf:type, genealogy:Person), and(!=(v15,v16), !=(v14,v16))))))))) then and(rdf(v15, rdf:type, genealogy:Aunt), rdf(v16, genealogy:aunt, v15))."))
			assertTrue(processorProvider.get.compareTranslations(rules.get(7).toString(),"Rule UncleRule:  if and(rdf(v17, rdf:type, genealogy:Person), and(rdf(v17, genealogy:sibling, v18), and(rdf(v18, rdf:type, genealogy:Person), and(!=(v17,v18), and(rdf(v18, genealogy:gender, genealogy:Male), and(rdf(v17, genealogy:child, v19), and(rdf(v19, rdf:type, genealogy:Person), and(!=(v18,v19), !=(v17,v19))))))))) then and(rdf(v18, rdf:type, genealogy:Uncle), rdf(v19, genealogy:uncle, v18))."))
			assertTrue(processorProvider.get.compareTranslations(rules.get(8).toString(),"Rule CousinRule:  if and(rdf(v20, rdf:type, genealogy:Person), and(rdf(v20, genealogy:sibling, v21), and(rdf(v21, rdf:type, genealogy:Person), and(!=(v20,v21), and(rdf(v20, genealogy:child, v22), and(rdf(v22, rdf:type, genealogy:Person), and(!=(v21,v22), and(!=(v20,v22), and(rdf(v21, genealogy:child, v23), and(rdf(v23, rdf:type, genealogy:Person), and(!=(v22,v23), and(!=(v21,v23), !=(v20,v23))))))))))))) then rdf(v22, genealogy:cousin, v23)."))
		]
		
	}

	protected def Resource assertValidatesTo(CharSequence code, (OntModel, List<Rule>, List<SadlCommand>, List<Issue>)=>void assertions) {
		val model = parser.parse(code)
		validationTestHelper.assertNoErrors(model)
		val processor = processorProvider.get
		val List<Issue> issues= newArrayList
		processor.onValidate(model.eResource, new ValidationAcceptorImpl([issues += it]),  CheckMode.FAST_ONLY, new ProcessorContext(CancelIndicator.NullImpl,  preferenceProvider.getPreferenceValues(model.eResource)))
		assertions.apply(processor.theJenaModel, processor.rules, processor.sadlCommands, issues)
		return model.eResource
	}

}