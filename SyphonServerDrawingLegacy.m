//
//  SyphonServerDrawingLegacy.m
//  Syphon
//
//  Created by Eduardo Roman on 1/26/15.
//
//

#import "SyphonServerDrawingLegacy.h"
#import <IOSurface/IOSurface.h>
#import <OpenGL/CGLMacro.h>

@implementation SyphonServerDrawingLegacy

- (void)drawFrameTexture:(GLuint)texID textureTarget:(GLenum)target imageRegion:(NSRect)region textureDimensions:(NSSize)size surfaceSize:(NSSize)surfaceSize flipped:(BOOL)isFlipped inContex:(CGLContextObj)cgl_ctx discardAlpha:(BOOL)discardAlpha{

    
    
    glPushAttrib(GL_ALL_ATTRIB_BITS);
    glPushClientAttrib(GL_CLIENT_ALL_ATTRIB_BITS);
    // Setup OpenGL states
    glViewport(0, 0, surfaceSize.width,  surfaceSize.height);
    
    // We need to ensure we set this before changing our texture matrix
    glActiveTexture(GL_TEXTURE0);
    // ensure we act on the proper client texture as well
    glClientActiveTexture(GL_TEXTURE0);
    
    glMatrixMode(GL_TEXTURE);
    glPushMatrix();
    glLoadIdentity();
    
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    glOrtho(0, surfaceSize.width, 0, surfaceSize.height, -1, 1);
    
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();
				
    // dont bother clearing. we dont have any alpha so we just write over the buffer contents. saves us a write.
    // via GL_REPLACE TEX_ENV
    glEnable(target);
    glBindTexture(target, texID);
    
    // set up texture combiner.
    if(discardAlpha)
    {
        // (r, g, b, 1)
        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
        glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_REPLACE);
        glTexEnvf(GL_TEXTURE_ENV, GL_SRC0_RGB, GL_TEXTURE);
        glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_REPLACE);
        glTexEnvf(GL_TEXTURE_ENV, GL_SRC0_ALPHA, GL_CONSTANT);
        const float texEnvColor[] = {1.0f, 1.0f, 1.0f, 1.0f};
        glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, texEnvColor);
    }
    else
    {
        // (r, g, b, a)
        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    }
    
    // why do we need it ?
    glDisable(GL_BLEND);
    
    GLfloat tex_coords[8];
    
    if(target == GL_TEXTURE_2D)
    {
        // Cannot assume mip-mapping and repeat modes are ok & will work, so we:
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);	// Linear Filtering
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);	// Linear Filtering
        
        GLfloat texOriginX = region.origin.x / size.width;
        GLfloat texOriginY = region.origin.y / size.height;
        GLfloat texExtentX = (region.size.width + region.origin.x) / size.width;
        GLfloat texExtentY = (region.size.height + region.origin.y) / size.height;
        
        if(!isFlipped)
        {
            // X							// Y
            tex_coords[0] = texOriginX;		tex_coords[1] = texOriginY;
            tex_coords[2] = texOriginX;		tex_coords[3] = texExtentY;
            tex_coords[4] = texExtentX;		tex_coords[5] = texExtentY;
            tex_coords[6] = texExtentX;		tex_coords[7] = texOriginY;
        }
        else
        {
            tex_coords[0] = texOriginX;		tex_coords[1] = texExtentY;
            tex_coords[2] = texOriginX;		tex_coords[3] = texOriginY;
            tex_coords[4] = texExtentX;		tex_coords[5] = texOriginY;
            tex_coords[6] = texExtentX;		tex_coords[7] = texExtentY;
        }
    }
    else
    {
        if(!isFlipped)
        {	// X													// Y
            tex_coords[0] = region.origin.x;						tex_coords[1] = 0.0;
            tex_coords[2] = region.origin.x;						tex_coords[3] = region.size.height + region.origin.y;
            tex_coords[4] = region.size.width + region.origin.x;	tex_coords[5] = region.size.height + region.origin.y;
            tex_coords[6] = region.size.width + region.origin.x;	tex_coords[7] = 0.0;
        }
        else
        {
            tex_coords[0] = region.origin.x;						tex_coords[1] = region.size.height + region.origin.y;
            tex_coords[2] = region.origin.x;						tex_coords[3] = region.origin.y;
            tex_coords[4] = surfaceSize.width;						tex_coords[5] = region.origin.y;
            tex_coords[6] = surfaceSize.width;						tex_coords[7] = region.size.height + region.origin.y;
        }
    }
    
    GLfloat verts[] =
    {
        0.0f, 0.0f,
        0.0f, surfaceSize.height,
        surfaceSize.width, surfaceSize.height,
        surfaceSize.width, 0.0f,
    };
    
    // Ought to cache the GL_ARRAY_BUFFER_BINDING, GL_ELEMENT_ARRAY_BUFFER_BINDING, set buffer to 0, and reset
    GLint arrayBuffer, elementArrayBuffer;
    glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &elementArrayBuffer);
    glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &arrayBuffer);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glEnableClientState( GL_TEXTURE_COORD_ARRAY );
    glTexCoordPointer(2, GL_FLOAT, 0, tex_coords );
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, verts );
    glDrawArrays( GL_TRIANGLE_FAN, 0, 4 );
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementArrayBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, arrayBuffer);
    
    glBindTexture(target, 0);
    
    // Restore OpenGL states
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix();
    
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    
    
    glMatrixMode(GL_TEXTURE);
    glPopMatrix();
    
    glPopClientAttrib();
    glPopAttrib();

}

@end
