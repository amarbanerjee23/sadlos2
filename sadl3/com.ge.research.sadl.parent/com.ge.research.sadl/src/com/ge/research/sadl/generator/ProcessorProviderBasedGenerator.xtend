/*
 * generated by Xtext 2.9.0-SNAPSHOT
 */
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
package com.ge.research.sadl.generator

import com.ge.research.sadl.processing.IModelProcessor.ProcessorContext
import com.ge.research.sadl.processing.IModelProcessorProvider
import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.eclipse.xtext.preferences.IPreferenceValuesProvider

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class ProcessorProviderBasedGenerator extends AbstractGenerator {

	@Inject IModelProcessorProvider processorProvider 
	@Inject IPreferenceValuesProvider preferenceProvider
	
	override doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext ctx) {
		val processor = processorProvider.getProcessor(resource)
		processor.onGenerate(resource, fsa, new ProcessorContext(ctx.cancelIndicator,  preferenceProvider.getPreferenceValues(resource)))
	}
	
}
