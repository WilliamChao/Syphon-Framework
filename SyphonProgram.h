//
//  SyphonProgram.h
//  Syphon
//
//  Created by Eduardo Roman on 1/26/15.
//
//

#import <Foundation/Foundation.h>

@interface SyphonProgram : NSObject
@property(readonly) GLint program;
-(void)use;
-(void)setRegion:(NSRect)region size:(NSSize)size flipped:(BOOL)isFlipped;
+(void)unUse;

@end
