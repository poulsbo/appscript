//
//  bridgedata.m
//  Appscript
//

#import "bridgedata.h"

@implementation ASBridgeData

- (id)initWithApplicationClass:(Class)appClass
					targetType:(ASTargetType)type
					targetData:(id)data
				   terminology:(id)terms_
				  defaultTerms:(ASTerminology *)defaultTerms_
			  keywordConverter:(id)converter_ {
	self = [super initWithApplicationClass: appClass targetType: type targetData: data];
	if (!self) return self;
	terms = terms_;
	defaultTerms = defaultTerms_;
	converter = converter_;
	return self;
}


- (id)copyWithZone:(NSZone *)zone {
	ASBridgeData *obj = [super copyWithZone: zone];
	if (!obj) return obj;
	return obj;
}

- (id)aetesWithError:(out NSError **)error {
	AEMApplication *targetApp;
	AEMEvent *event;
	
	targetApp = [self targetWithError: error];
	if (!targetApp) return nil;
	event = [targetApp eventWithEventClass: kASAppleScriptSuite eventID: kGetAETE];
	[event setParameter: [NSNumber numberWithInt: 0] forKeyword: keyDirectObject];
	return [event sendWithError: error];
}

- (BOOL)connectWithError:(out NSError **)error {
	ASTerminology *tmp;
	ASAETEParser *parser;
	id aetes;
	
	if (![super connectWithError: error]) return NO;
	if ([terms isEqual: ASTrue]) { // obtain terminology from application
		aetes = [self aetesWithError: error];
		if (!aetes) return NO;
		parser = [[ASAETEParser alloc] init];
		[parser parse: aetes];
		terms = [[ASTerminology alloc] initWithKeywordConverter: converter defaultTerminology: defaultTerms];
		[terms addClasses: [parser classes]
			  enumerators: [parser enumerators]
			   properties: [parser properties]
				 elements: [parser elements]
				 commands: [parser commands]];
	} else if ([terms isEqual: ASFalse]) { // use built-in terminology only (e.g. use this when running AppleScript applets)
		terms = defaultTerms;
	} else { // terms is [assumed to be] an ASAETEParser instance or equivalent object containing raw (dumped) terminology
		tmp = [[ASTerminology alloc] initWithKeywordConverter: converter defaultTerminology: defaultTerms];
		[tmp addClasses: [(ASAETEParser *)terms classes] 
			enumerators: [(ASAETEParser *)terms enumerators] 
			 properties: [(ASAETEParser *)terms properties] 
			   elements: [(ASAETEParser *)terms elements] 
			   commands: [(ASAETEParser *)terms commands]];
		terms = tmp;
	}
	return YES;
}

- (ASTargetType)targetType {
	return targetType;
}

- (id)targetData {
	return targetData;
}

- (ASTerminology *)terminology {
	if (!target) return nil;
	return terms;
}

@end
