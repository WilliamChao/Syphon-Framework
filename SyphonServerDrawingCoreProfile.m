//
//  SyphonServerDrawingCoreProfile.m
//  Draws frame texture in the core profile mode
//
//  Originally created by Eduardo Roman on 1/26/15.
//  Modified by Keijiro Takahashi
//

#import "SyphonServerDrawingCoreProfile.h"
#import <OpenGL/gl3.h>
#import "SyphonProgram.h"

@implementation SyphonServerDrawingCoreProfile {
    SyphonProgram* _syphonProgram;
}

- (void)drawFrameTexture:(GLuint)texID textureTarget:(GLenum)target imageRegion:(NSRect)region textureDimensions:(NSSize)size surfaceSize:(NSSize)surfaceSize flipped:(BOOL)isFlipped inContex:(CGLContextObj)cgl_ctx discardAlpha:(BOOL)discardAlpha
{
    CGLSetCurrentContext(cgl_ctx);
    
    if (_syphonProgram == nil)
    {
        _syphonProgram = [[SyphonProgram alloc] init];
        if (_syphonProgram == nil) return;
    }
    
    glViewport(0, 0, surfaceSize.width, surfaceSize.height);
    
    _syphonProgram.discardAlpha = discardAlpha;
    [_syphonProgram use];
    
    glDisable(GL_CULL_FACE);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(target, texID);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
