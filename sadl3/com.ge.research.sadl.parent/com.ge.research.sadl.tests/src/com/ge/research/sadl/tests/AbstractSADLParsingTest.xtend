/************************************************************************
 * Copyright © 2007-2016 - General Electric Company, All Rights Reserved
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
/*
 * generated by Xtext 2.9.0-SNAPSHOT
 */
package com.ge.research.sadl.tests

import com.ge.research.sadl.sADL.SadlModel
import com.google.common.base.Supplier
import com.google.common.base.Suppliers
import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.util.StringInputStream
import org.junit.Assert
import org.junit.Before
import org.junit.runner.RunWith

@RunWith(XtextRunner)
@InjectWith(SADLInjectorProvider)
abstract class AbstractSADLParsingTest{
	@Inject extension ValidationTestHelper

	@Inject ParseHelper<SadlModel> parseHelper
	@Inject protected ValidationTestHelper validationTestHelper
	@Inject Provider<XtextResourceSet> resourceSetProvider
	XtextResourceSet resourceSet

	static val IMPLICIT_MODEL = '''uri "http://sadl.org/sadlimplicitmodel" alias sadlimplicitmodel.
	Event is a class.
		impliedProperty is a type of annotation.
		UnittedQuantity is a class,
	 	described by ^value with values of type decimal,
	 	described by unit with values of type string.
	'''

	private final Supplier<Void> implicitModelSupplier = Suppliers.memoize[
		val uri = URI.createURI('synthetic://test/SadlImplicitModel.sadl');
		if (!resourceSet.resources.map[uri.lastSegment].exists[it == 'SadlImplicitModel.sadl']) {
			resource(IMPLICIT_MODEL, uri);
		}
		return null;
	]
	
	@Before
	def void initialize() {
		resourceSet = resourceSetProvider.get
	}
		
	protected def void assertNoErrors(CharSequence text) {
		val model = parseHelper.parse(text)
		val issues = validationTestHelper.validate(model)
		if (issues.isEmpty)
			return;
		var String annotatedText = text.toString
		for (issue : issues.filter[isSyntaxError].sortBy[-offset]) {
			annotatedText = annotatedText.substring(0, issue.offset) + '''[«issue.message»]''' + annotatedText.substring(issue.offset)
		}
		Assert.assertEquals(text.toString, annotatedText)
	}
	
	protected def void assertErrors(CharSequence text, String[] errPartials) {
		val model = parseHelper.parse(text)
		val issues = validationTestHelper.validate(model)
		Assert.assertFalse(issues.isEmpty)
		Assert.assertEquals(issues.size, 1)
		for (err : errPartials) {
			var found = false
			for (issue : issues) {
				if (issue.message.contains(err)) {
					found = true
				}
			}
			Assert.assertTrue(found)
		}
	}
	
	protected def Resource sadl(CharSequence seq) {
		// This will create one single implicit model instance into the resource set
		// per test method no matter how many times it is invoked.
		implicitModelSupplier.get;
		return resource(seq, 'sadl');
	}
	
	protected def Resource resource(CharSequence seq, String fileExtension) {
		val name = "Resource" + resourceSet.resources.size + "." + fileExtension;
		return resource(seq, URI.createURI("synthetic://test/" + name));
	}
	
	protected def Resource resource(CharSequence seq, URI uri) {
		val resource = resourceSet.createResource(uri);
		resource.load(new StringInputStream(seq.toString), null);
		return resource;
	}

	def void assertAST(CharSequence text, (SadlModel)=>void assertion) {
		val model = parseHelper.parse(text)
		validationTestHelper.assertNoErrors(model)
		assertion.apply(model)
	}
	
	def String prependUri(CharSequence sequence) {
		return '''
			«model»
			«sequence»
		'''
	}
	
	protected def String model() {
		val name = Thread.currentThread.stackTrace.findFirst[className!=AbstractSADLParsingTest.simpleName].methodName
		return '''uri "http://sadl.org/TestSadl/«name»" alias «name».'''
	}

	protected def void assertNoErrors(Resource resource) {
		val issues = validate(resource).toList.sortBy[-(offset?:0)]
		val text = (resource as XtextResource).parseResult.rootNode.text
		var errorText = text
		if (text === null) {
			issues.head.data
			Assert.fail(issues.join(',')[message])
		}
		for (issue : issues) {
			if (issue.offset === null || issue.length === null) {
				errorText = errorText+"\n!["+issue.message+"] ATTENTION : The produced issue doesn't have an offset or length attached!"
			} else {
				errorText = errorText.substring(0, issue.offset)+"!"+errorText.substring(issue.offset, issue.offset + issue.length)+"!["+issue.message+"]"+errorText.substring(issue.offset+issue.length)
			}
		}
		Assert.assertEquals(text, errorText)
	}
	
	protected def void assertOnlyWarningsOrInfo(Resource resource) {
		val issues = validate(resource).toList.sortBy[-(offset?:0)]
		val text = (resource as XtextResource).parseResult.rootNode.text
		var errorText = text
		if (text === null) {
			issues.head.data
			Assert.fail(issues.join(',')[message])
		}
		for (issue : issues) {
			if (issue.severity == Severity.ERROR) {
				if (issue.offset === null || issue.length === null) {
					errorText = errorText+"\n!["+issue.message+"] ATTENTION : The produced issue doesn't have an offset or length attached!"
				} else {
					errorText = errorText.substring(0, issue.offset)+"!"+errorText.substring(issue.offset, issue.offset + issue.length)+"!["+issue.message+"]"+errorText.substring(issue.offset+issue.length)
				}
			}
		}
		Assert.assertEquals(text, errorText)
	}
	
	protected def void assertError(Resource resource, String error) {
		val issues = validate(resource).toList.sortBy[-(offset?:0)]
		val text = (resource as XtextResource).parseResult.rootNode.text
		var errorText = text
		if (text === null) {
			issues.head.data
			Assert.fail(issues.join(',')[message])
		}
		var errorFound = false
		for (issue : issues) {
			if (!errorFound && issue.severity == Severity.ERROR) {
				if (issue.offset === null || issue.length === null) {
					errorText = errorText+"\n!["+issue.message+"] ATTENTION : The produced issue doesn't have an offset or length attached!"
				}
				else if (issue.message.startsWith(error)) {
					errorFound = true
				} else {
					errorText = errorText.substring(0, issue.offset)+"!"+errorText.substring(issue.offset, issue.offset + issue.length)+"!["+issue.message+"]"+errorText.substring(issue.offset+issue.length)
				}
			}
		}
		Assert.assertEquals(text, errorText)
	}
	
}
