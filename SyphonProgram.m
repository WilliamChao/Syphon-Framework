//
//  SyphonProgram.m
//  Syphon
//
//  Created by Eduardo Roman on 1/26/15.
//
//

#import "SyphonProgram.h"
#import <OpenGL/gl3.h>

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)


NSString *const vertexShaderString = SHADER_STRING
(
out vec2 v_texcoord;

void main(void)
{
    int id = gl_VertexID;
    
    v_texcoord = vec2((id == 2) ?  2.0 :  0.0,
                      (id == 1) ?  2.0 :  0.0);

    gl_Position = vec4(v_texcoord * vec2(2.0, -2.0) + vec2(-1.0, 1.0), 1.0, 1.0);
}
);



NSString *const fragmentShaderString = SHADER_STRING
(

 uniform sampler2D u_color;
 uniform vec4 u_region;
 uniform vec2 u_tex_size;
 uniform int u_flip;
 
 in vec2 v_texcoord;

 out vec4 o_frag_color;
 
 void main(void){
    vec2 uv = vec2(v_texcoord.x, 1.0 - v_texcoord.y);
    o_frag_color = texture(u_color, uv);
}
);

@implementation SyphonProgram{
    GLint vertexShaderHandle;
    GLint fragmentShaderHandle;
    GLint handle;
    
    GLuint u_color_location;
    GLuint u_region_location;
    GLuint u_flip_location;
    GLuint u_tex_size_location;

}

-(GLint)program{
    return handle;
}

-(GLint)createShaderWithType:(GLenum)type andSource:(NSString*)source{
    GLint mHandle = glCreateShader(type);
    const char *s = [source cStringUsingEncoding:NSUTF8StringEncoding];
    glShaderSource(mHandle, 1, &s, NULL);
    glCompileShader(mHandle);
    GLint res = 0;
    glGetShaderiv(mHandle, GL_COMPILE_STATUS, &res);
    if(res == GL_TRUE){
        return mHandle;
    }
    else{
        GLchar info[512] = "";
        GLsizei l = 511;
        glGetShaderInfoLog(mHandle, l, &l, info);
        NSString *msg = [NSString stringWithCString:info encoding:NSUTF8StringEncoding];
        NSLog(@"Compiler message: %@", msg);
        return 0;
    }
}


- (BOOL)validate:(GLint)mHandle{
    glValidateProgram(mHandle);
    
    GLint res = 0;
    glGetProgramiv(mHandle, GL_VALIDATE_STATUS, &res);
    //GLLog(@"validate: %d", res);
    if(res == GL_TRUE)
    {
        return YES;
    }
    else
    {
        GLchar info[512] = "";
        GLsizei l = 511;
        glGetProgramInfoLog(mHandle, l, &l, info);
        
        NSString *msg = [NSString stringWithCString:info encoding:NSUTF8StringEncoding];
        NSLog(@"Validate message: %@", msg);
        
        return NO;
    }
}


-(instancetype)init{
    self = [super init];
    if(self){
        NSString *vxStr = [NSString stringWithFormat:@"#version 150\n%@",vertexShaderString];
        NSString *fgStr = [NSString stringWithFormat:@"#version 150\n%@",fragmentShaderString];
        vertexShaderHandle = [self createShaderWithType:GL_VERTEX_SHADER andSource:vxStr];
        fragmentShaderHandle = [self createShaderWithType:GL_FRAGMENT_SHADER andSource:fgStr];
        handle = glCreateProgram();
        glAttachShader(handle, vertexShaderHandle);
        glAttachShader(handle, fragmentShaderHandle);
        glLinkProgram(handle);
        if(![self validate:handle]){
            self = nil;
        }
        glBindFragDataLocation(handle, 0, "o_frag_color");

        
        u_color_location = glGetUniformLocation(handle, "u_color");
        u_region_location = glGetUniformLocation(handle, "u_region");
        u_tex_size_location = glGetUniformLocation(handle, "u_tex_size");
        u_flip_location = glGetUniformLocation(handle, "u_flip");


    }
    return self;
}


-(void)setRegion:(NSRect)region size:(NSSize)size flipped:(BOOL)isFlipped{
    glUniform1i(u_color_location, 0);
    glUniform4f(u_region_location, region.origin.x, region.origin.y,region.size.height, region.size.height);
    glUniform2f(u_tex_size_location, size.width, size.height);
    glUniform1i(u_flip_location, isFlipped);
}


- (void)use{
    glUseProgram(handle);
}

+(void)unUse{
    glUseProgram(0);
}


@end
