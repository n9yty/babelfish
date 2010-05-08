//
//  TestHelper.h
//  Babelfish
//
//  Created by Filip Krikava on 5/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class BFLanguage;

extern BFLanguage *autoDetect;

extern BFLanguage *english;
extern BFLanguage *africans;
extern BFLanguage *french;

void BFTestHelperInitialize();
void BFTestHelperStubBasicTranslatorMethods(id mock);
