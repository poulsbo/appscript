//
//  unittype.m
//  aem
//

#import "unittype.h"


/**********************************************************************/
// default unit types

typedef struct {
	const char *name;
	DescType code;
} AEMDefaultUnitTypeDef;


static AEMDefaultUnitTypeDef defaultUnitTypes[] = {
	{"centimeters", 'cmtr'},
	{"meters", 'metr'},
	{"kilometers", 'kmtr'},
	{"inches", 'inch'},
	{"feet", 'feet'},
	{"yards", 'yard'},
	{"miles", 'mile'},
	
	{"square meters", 'sqrm'},
	{"square kilometers", 'sqkm'},
	{"square feet", 'sqft'},
	{"square yards", 'sqyd'},
	{"square miles", 'sqmi'},
	
	{"cubic centimeters", 'ccmt'},
	{"cubic meters", 'cmet'},
	{"cubic inches", 'cuin'},
	{"cubic feet", 'cfet'},
	{"cubic yards", 'cyrd'},
	
	{"liters", 'litr'},
	{"quarts", 'qrts'},
	{"gallons", 'galn'},
	
	{"grams", 'gram'},
	{"kilograms", 'kgrm'},
	{"ounces", 'ozs '},
	{"pounds", 'lbs '},
	
	{"degrees Celsius", 'degc'},
	{"degrees Fahrenheit", 'degf'},
	{"degrees Kelvin", 'degk'},
	{nil, 0}
};


/**********************************************************************/
// Unit type definition

@implementation AEMUnitTypeDefinition

+ (id)definitionWithName:(NSString *)name_ code:(DescType)code_ {
	return [[[self class] alloc] initWithName: name_ code: code_];
}

- (id)initWithName:(NSString *)name_ code:(DescType)code_ {
	self = [super init];
	if (!self) return self;
	name = name_;
	code = code_;
	return self;
}


- (NSString *)name {
	return name;
}

- (DescType)code {
	return code;
}

/*
 * The default implementation packs and unpacks the descriptor's data
 * handle as a double. Override these methods to support other formats.
 */
- (NSAppleEventDescriptor *)pack:(ASUnits *)obj {
	double float64 = [obj doubleValue];
	return [NSAppleEventDescriptor descriptorWithDescriptorType: code
														  bytes: &float64
														 length: sizeof(float64)];
}

- (ASUnits *)unpack:(NSAppleEventDescriptor *)desc {
	double float64;
	[[desc data] getBytes: &float64 length: sizeof(float64)];
	return [ASUnits unitsWithDouble: float64 type: name];
}

@end


/**********************************************************************/

void AEMGetDefaultUnitTypeDefinitions(NSMutableDictionary **definitionsByName,
                                      NSMutableDictionary **definitionsByCode) {
	static NSMutableDictionary *defaultDefinitionsByName, *defaultDefinitionsByCode;
	NSString *name;
	DescType code;
	AEMUnitTypeDefinition *definition;
	int i = 0;
	
	if (!defaultDefinitionsByName) {
		defaultDefinitionsByName = [[NSMutableDictionary alloc] init];
		defaultDefinitionsByCode = [[NSMutableDictionary alloc] init];
		do {
			name = [NSString stringWithUTF8String:defaultUnitTypes[i].name];
			code = defaultUnitTypes[i].code;
			definition = [[AEMUnitTypeDefinition alloc] initWithName: name code: code];
			[defaultDefinitionsByName setObject: definition forKey: name];
			[defaultDefinitionsByCode setObject: definition forKey: [NSNumber numberWithUnsignedInt: code]];
			i++;
		} while (defaultUnitTypes[i].name);
	}
	*definitionsByName = [NSMutableDictionary dictionaryWithDictionary: defaultDefinitionsByName];
	*definitionsByCode = [NSMutableDictionary dictionaryWithDictionary: defaultDefinitionsByCode];
}

