//
//  SyphonServerDrawingCoreProfile.m
//  Syphon
//
//  Created by Eduardo Roman on 1/26/15.
//
//

#import "SyphonServerDrawingCoreProfile.h"
#import <OpenGL/gl3.h>
#import "SyphonProgram.h"




@implementation SyphonServerDrawingCoreProfile{
    SyphonProgram*syphonProgram;
}


- (void)drawFrameTexture:(GLuint)texID textureTarget:(GLenum)target imageRegion:(NSRect)region textureDimensions:(NSSize)size surfaceSize:(NSSize)surfaceSize flipped:(BOOL)isFlipped inContex:(CGLContextObj)cgl_ctx discardAlpha:(BOOL)discardAlpha{
    
    CGLSetCurrentContext(cgl_ctx);
    
    if(nil==syphonProgram){
        syphonProgram = [[SyphonProgram alloc] init];
    }
    
    if(nil == syphonProgram){
        return;
    }
    
    
    glDisable(GL_CULL_FACE);
    glViewport(0, 0, surfaceSize.width, surfaceSize.height);
    [syphonProgram use];
    [syphonProgram setRegion:region size:size flipped:isFlipped];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(target, texID);    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glUseProgram(0);
}

@end
