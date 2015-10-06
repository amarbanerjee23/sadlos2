/*
 * generated by Xtext 2.9.0-SNAPSHOT
 */
package com.ge.research.sadl.formatting2

import com.ge.research.sadl.sADL.Greeting
import com.ge.research.sadl.sADL.Model
import com.ge.research.sadl.services.SADLGrammarAccess
import com.google.inject.Inject
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument

class SADLFormatter extends AbstractFormatter2 {
	
	@Inject extension SADLGrammarAccess

	def dispatch void format(Model model, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		for (Greeting greetings : model.getGreetings()) {
			format(greetings, document);
		}
	}
}
