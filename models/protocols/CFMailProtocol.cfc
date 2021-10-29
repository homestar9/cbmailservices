﻿<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano & Robert Rawlings
Description :
A mail protocol that sends via email
----------------------------------------------------------------------->
<cfcomponent
	extends="cbmailservices.models.AbstractProtocol"
	output ="false"
	hint   ="A mail protocol that sends via email"
>
	<!--- init --->
	<cffunction
		name      ="init"
		access    ="public"
		returntype="CFMailProtocol"
		hint      ="Constructor"
		output    ="false"
	>
		<cfargument
			name    ="properties"
			required="false"
			default ="#structNew()#"
			hint    ="A map of configuration properties for the protocol"
		/>
		<cfscript>
		variables.name = "CFMail";
		super.init( argumentCollection = arguments );

		return this;
		</cfscript>
	</cffunction>

	<!------------------------------------------- PUBLIC ------------------------------------------>

	<cffunction
		name      ="send"
		access    ="public"
		returntype="struct"
		hint      ="I send a payload via the cfmail protocol."
	>
		<cfargument
			name       ="payload"
			required   ="true"
			type       ="any"
			hint       ="I'm the payload to delivery"
			doc_generic="cbmailservices.models.mail"
		/>
		<cfscript>
		// The return structure
		var rtnStruct      = structNew();
		rtnStruct.error    = true;
		rtnStruct.messages = arrayNew( 1 );

		// Just mail the darned thing!!
		try {
			// Determine Mail Type?
			if ( arrayLen( arguments.payload.getMailParts() ) ) {
				mailMultiPart( arguments.payload );
			} else {
				mailNormal( arguments.payload );
			}

			// send success
			rtnStruct.error = false;
		} catch ( Any e ) {
			arrayAppend(
				rtnStruct.messages,
				"Error sending mail. #e.message# : #e.detail# : #e.stackTrace#"
			);
		}

		// Return the return structure.
		return rtnStruct;
		</cfscript>
	</cffunction>

	<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- mailNormal --->
	<cffunction
		name      ="mailNormal"
		output    ="false"
		access    ="private"
		returntype="void"
		hint      ="Mail a payload"
	>
		<cfargument
			name       ="mail"
			required   ="true"
			type       ="any"
			hint       ="The mail payload"
			doc_generic="cbmailservices.models.Mail"
		/>
		<cfset var payload = arguments.mail>
		<cfset var mailParam = 0>

		<cfsetting enablecfoutputonly="true">

		<!--- I HATE FREAKING CF WHITESPACE, LOOK HOW UGLY THIS IS --->
		<cfmail attributeCollection="#payload.getConfig()#">
			<cfoutput>#payload.getBody()#</cfoutput>
			<cfsilent>
				<cfloop array="#payload.getMailParams()#" index="mailparam">
					<cfif structKeyExists( mailParam, "name" )>
						<cfmailparam name="#mailparam.name#" attributeCollection="#mailParam#">
					<cfelseif structKeyExists( mailparam, "file" )>
						<cfmailparam file="#mailparam.file#" attributeCollection="#mailParam#">
					</cfif>
				</cfloop>
			</cfsilent>
		</cfmail>

		<cfsetting enablecfoutputonly="false">
	</cffunction>

	<cffunction
		name      ="mailMultiPart"
		output    ="false"
		access    ="private"
		returntype="any"
		hint      ="Mail a payload using multi part objects"
	>
		<cfargument
			name       ="mail"
			required   ="true"
			type       ="any"
			hint       ="The mail payload"
			doc_generic="cbmailservices.models.Mail"
		/>
		<cfset var payload = arguments.mail>
		<cfset var mailParam = 0>
		<cfset var mailPart = 0>

		<cfsetting enablecfoutputonly="true">

		<!--- I HATE FREAKING CF WHITESPACE, LOOK HOW UGLY THIS IS --->
		<cfmail attributeCollection="#payload.getConfig()#">
			<!--- Mail Params --->
			<cfloop array="#payload.getMailParams()#" index="mailparam">
				<cfif structKeyExists( mailParam, "name" )>
					<cfmailparam name="#mailparam.name#" attributeCollection="#mailParam#">
				<cfelseif structKeyExists( mailparam, "file" )>
					<cfmailparam file="#mailparam.file#" attributeCollection="#mailParam#">
				</cfif>
			</cfloop>
			<!--- Mail Parts --->
			<cfloop array="#payload.getMailParts()#" index="mailPart">
				<cfmailpart attributeCollection="#mailpart#">
					<cfoutput>#mailpart.body#</cfoutput>
				</cfmailpart>
			</cfloop>
		</cfmail>

		<cfsetting enablecfoutputonly="false">
	</cffunction>
</cfcomponent>
