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
out vec3 v_texcoord;

void main(void)
{
    int id = gl_VertexID;
    
    v_texcoord = vec3((id == 2) ?  2.0 :  0.0,
                      (id == 1) ?  2.0 :  0.0,
                      1.0);
  

    gl_Position = vec4(v_texcoord.xy * vec2(2.0, -2.0) + vec2(-1.0, 1.0), 1.0, 1.0);
}
);



NSString *const fragmentShaderString = SHADER_STRING
(

 uniform sampler2DRect u_color;
 layout(origin_upper_left) in vec4 gl_FragCoord;
 
 out vec4 o_frag_color;
 
 void main(void)
{
    vec2 v_texcoord = vec2(gl_FragCoord.s, gl_FragCoord.t);

    o_frag_color = texture(u_color, v_texcoord);
}
);

@implementation SyphonProgram{
    GLint vertexShaderHandle;
    GLint fragmentShaderHandle;
    GLint handle;
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

        //[command setTexture:_texture target:GL_TEXTURE_RECTANGLE unit:GL_TEXTURE0];
        //[command setUniform:[GLValue valueWithInt:0] forName:@"u_color"];

    }
    return self;
}

- (void)use{
    glUseProgram(handle);
}



@end
