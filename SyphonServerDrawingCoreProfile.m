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
    SyphonProgram*program;
}


- (void)drawFrameTexture:(GLuint)texID textureTarget:(GLenum)target imageRegion:(NSRect)region textureDimensions:(NSSize)size surfaceSize:(NSSize)surfaceSize flipped:(BOOL)isFlipped inContex:(CGLContextObj)cgl_ctx{
    
    CGLSetCurrentContext(cgl_ctx);
    
    if(nil==program){
        program = [[SyphonProgram alloc] init];
    }
    
    if(nil == program){
        return;
    }
    
    glViewport(0, 0, size.width, size.height);
    glUseProgram(program.program);
    GLint uniformLoacation = glGetUniformLocation(program.program, "u_color");

    glUniform1i(uniformLoacation, 0);

    //glUniform1iv(location, mCount, self.intValues);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(target, texID);
    
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glUseProgram(0);
}

@end
