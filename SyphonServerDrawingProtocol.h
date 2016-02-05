//
//  SyphonServerDrawingProtocol.h
//  Syphon
//
//  Created by Eduardo Roman on 1/26/15.
//
//

#ifndef Syphon_SyphonServerDrawingProtocol_h
#define Syphon_SyphonServerDrawingProtocol_h


@protocol SyphonServerDrawingProtocol <NSObject>
- (void)drawFrameTexture:(GLuint)texID textureTarget:(GLenum)target imageRegion:(NSRect)region textureDimensions:(NSSize)size surfaceSize:(NSSize)surfaceSize flipped:(BOOL)isFlipped inContex:(CGLContextObj)cgl_ctx discardAlpha:(BOOL)discardAlpha;
@end



#endif
