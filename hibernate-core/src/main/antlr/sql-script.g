header
{
package org.hibernate.tool.schema.ast;

import java.util.Iterator;
import java.util.List;
import java.util.LinkedList;

import org.hibernate.hql.internal.ast.ErrorReporter;
}
/**
 * Lexer and parser used to extract single statements from import SQL script. Supports instructions/comments and quoted
 * strings spread over multiple lines. Each statement must end with semicolon.
 *
 * @author Lukasz Antoniak (lukasz dot antoniak at gmail dot com)
 */
class GeneratedSqlScriptParser extends Parser;

options {
    buildAST = false;
	k=3;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Semantic actions
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
    protected void out(String stmt) {
    	// by default, nothing to do
    }

    protected void out(Token token) {
    	// by default, nothing to do
    }

    protected void statementStarted() {
    	// by default, nothing to do
    }

    protected void statementEnded() {
    	// by default, nothing to do
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Parser rules
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

script
	: (statement)+ EOF
    ;

statement
	: { statementStarted(); } (statementPart)* DELIMITER (WS_CHAR)* { statementEnded(); }
	;

statementPart
	: quotedString
	| nonSkippedChar
	;

quotedString
	: q:QUOTED_TEXT {
		out( q );
	}
	;

nonSkippedChar
	: w:WS_CHAR {
   		out( w );
   	}
   	| o:OTHER_CHAR {
   		out( o );
   	}
	;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Lexer rules
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class SqlScriptLexer extends Lexer;

options {
    k = 2;
    charVocabulary = '\u0000'..'\uFFFE';
}

DELIMITER : ';' ;

// NOTE : The `ESCqs` part in the match is meant to an escaped quote (two single-quotes) and
// add it to the recognized text.  The `(ESCqs) => ESCqs` syntax is a syntactic predicate.
// We basically give precedence to the two single-quotes as a group as opposed to the first of them
// matching the terminal single-quote.  Both single-quotes end up in the quoted text
QUOTED_TEXT
	: '`' ( ~('`') )* '`'
	| '\'' ( (ESCqs) => ESCqs | ~('\'') )* '\''
//	: '\'' ( ~('\'') )* '\''
	;

protected
ESCqs :	'\'' '\'' ;

WS_CHAR
	: ' '
	| '\t'
	| ( "\r\n" | '\r' | '\n' ) {newline();}
    ;

OTHER_CHAR	: ~( ';' | ' ' | '\t' | '\n' | '\r' );

LINE_COMMENT
	// match `//` or `--` followed by anything other than \n or \r until NEWLINE
	: ("//" | "--") ( ~('\n'|'\r') )* {
		// skip the entire match from the lexer stream
		$setType( Token.SKIP );
	}
	;

/**
 * Note : this comes from the great Terrance Parr (author of Antlr) -
 *
 * https://theantlrguy.atlassian.net/wiki/spaces/ANTLR3/pages/2687360/How+do+I+match+multi-line+comments
 */
BLOCK_COMMENT
	: "/*"
          (               /* '\r' '\n' can be matched in one alternative or by matching
                             '\r' in one iteration and '\n' in another. I am trying to
                             handle any flavor of newline that comes in, but the language
                             that allows both "\r\n" and "\r" and "\n" to all be valid
                             newline is ambiguous. Consequently, the resulting grammar
                             must be ambiguous. I'm shutting this warning off.
                          */
            options {
              generateAmbigWarnings=false;
            }
            :  { LA(2)!='/' }? '*'
            | '\r' '\n' {newline();}
            | '\r' {newline();}
            | '\n' {newline();}
            | ~('*'|'\n'|'\r')
          )*
          "*/"
          {$setType(Token.SKIP);}
	;