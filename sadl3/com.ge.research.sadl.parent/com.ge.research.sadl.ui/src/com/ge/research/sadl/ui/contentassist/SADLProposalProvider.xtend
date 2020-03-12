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
package com.ge.research.sadl.ui.contentassist

import com.google.inject.Inject
import com.google.inject.Provider
import java.util.ArrayList
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistContext.Builder
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistEntry
import org.eclipse.xtext.ide.editor.contentassist.IIdeContentProposalAcceptor
import org.eclipse.xtext.ide.editor.contentassist.IdeContentProposalProvider
import org.eclipse.xtext.ui.editor.contentassist.AbstractContentProposalProvider.NullSafeCompletionProposalAcceptor
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import org.eclipse.xtext.ui.editor.contentassist.UiToIdeContentProposalProvider
import org.eclipse.xtext.util.TextRegion
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal

/**
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#content-assist
 * on how to customize the content assistant.
 */
class SADLProposalProvider extends AbstractSADLProposalProvider {

	@Inject
	SADLUiToIdeContentProposalProvider delegate;

	override createProposals(ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		delegate.createProposals(context, acceptor);
	}

	static class SADLUiToIdeContentProposalProvider extends UiToIdeContentProposalProvider {

		@Inject IdeContentProposalProvider ideProvider
		@Inject Provider<Builder> builderProvider

		override createProposals(ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
			val entries = new ArrayList<Pair<ContentAssistEntry, Integer>>
			val ideAcceptor = new IIdeContentProposalAcceptor {
				override accept(ContentAssistEntry entry, int priority) {
					if (entry !== null)
						entries += entry -> priority
				}

				override canAcceptMoreProposals() {
					entries.size < maxProposals
				}
			}
			ideProvider.createProposals(#[context.getIdeContext], ideAcceptor)
			val uiAcceptor = new NullSafeCompletionProposalAcceptor(acceptor)

			entries.forEach [ p, idx |
				val entry = p.key
				val proposal = doCreateProposal(entry.proposal, entry.displayString, entry.image, p.value, context)
				p.key.applySelection(proposal)
				uiAcceptor.accept(proposal)
			]
		}
		
		private def applySelection(ContentAssistEntry from, ConfigurableCompletionProposal to) {
			val editPositions = from.editPositions
			if (!editPositions.nullOrEmpty && editPositions.length === 1) {
				to.selectionStart = editPositions.head.offset
				to.selectionLength = editPositions.head.length
			}
		}

		private def org.eclipse.xtext.ide.editor.contentassist.ContentAssistContext getIdeContext(ContentAssistContext c) {
			val builder = builderProvider.get()
			val replaceRegion = c.replaceRegion
			builder
				.setPrefix(c.prefix)
				.setSelectedText(c.selectedText)
				.setRootModel(c.rootModel)
				.setRootNode(c.rootNode)
				.setCurrentModel(c.currentModel)
				.setPreviousModel(c.previousModel)
				.setCurrentNode(c.currentNode)
				.setLastCompleteNode(c.lastCompleteNode)
				.setOffset(c.offset)
				.setReplaceRegion(new TextRegion(replaceRegion.offset, replaceRegion.length))
				.setResource(c.resource)
			for (grammarElement : c.firstSetGrammarElements) {
				builder.accept(grammarElement)
			}
			return builder.toContext()
		}
		
	}

}
