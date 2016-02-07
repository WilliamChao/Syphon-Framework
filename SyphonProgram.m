//
//  SyphonProgram.m
//  Provides a program object used in the core profile mode
//
//  Originally created by Eduardo Roman on 1/26/15.
//  Modified by Keijiro Takahashi
//

#import "SyphonProgram.h"
#import <OpenGL/gl3.h>

#pragma mark Utility macros

#define SHADER_STRING(text) @"#version 150\n"#text

#pragma mark
#pragma mark Shader code

// Vertex shader code
NSString *const vertexShaderString = SHADER_STRING(
out vec2 v_texcoord;

void main(void)
{
    float i = gl_VertexID;
    float x = mod(i, 2);
    float y = floor(i / 2);
    // (0,0) - (1,0) - (0,1) - (1,1)
    v_texcoord = vec2(x, y);
    // (-1,1) - (1,1) - (-1,-1) - (1,-1)
    gl_Position = vec4(2 * x - 1, 1 - 2 * y, 1, 1);
}
);

// Fragment shader code
NSString *const fragmentShaderString = SHADER_STRING(
uniform sampler2D u_color;
uniform float u_alpha;

in vec2 v_texcoord;

out vec4 o_frag_color;

void main(void)
{
    vec2 uv = vec2(v_texcoord.x, 1 - v_texcoord.y);
    vec4 col = texture(u_color, uv);
    col.a = mix(col.a, 1, u_alpha); // discards alpha when u_alpha == 1
    o_frag_color = col;
}
);

// Initialize a shader with a given source.
static GLint InitShader(GLenum type, NSString* source)
{
    GLint shader = glCreateShader(type);
    const char* raw_source = [source cStringUsingEncoding:NSUTF8StringEncoding];
    
    glShaderSource(shader, 1, &raw_source, NULL);
    glCompileShader(shader);
    
    GLint res;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &res);
    if (res == GL_TRUE) return shader;
    
    // show error message
    GLchar info_raw[1024];
    glGetShaderInfoLog(shader, sizeof(info_raw), NULL, info_raw);
    NSString* info = [NSString stringWithCString:info_raw encoding:NSUTF8StringEncoding];
    NSLog(@"Shader compilation error: %@", info);
    return 0;
}

// Validate a program
static BOOL ValidateProgram(GLint program)
{
    glValidateProgram(program);
    
    GLint res;
    glGetProgramiv(program, GL_VALIDATE_STATUS, &res);
    if (res == GL_TRUE) return YES;
    
    // show error message
    GLchar info_raw[1024];
    glGetProgramInfoLog(program, sizeof(info_raw), NULL, info_raw);
    NSString* info = [NSString stringWithCString:info_raw encoding:NSUTF8StringEncoding];
    NSLog(@"Program validation error: %@", info);
    return 0;
}

#pragma mark
#pragma mark Class Implementation

@implementation SyphonProgram {
    BOOL _initialized;
    GLint _vertexShader;
    GLint _fragmentShader;
    GLint _program;
    BOOL _discardAlpha;
    GLuint _u_color_location;
    GLuint _u_alpha_location;
}

@synthesize program = _program;
@synthesize discardAlpha = _discardAlpha;

- (void)setup
{
    _vertexShader = InitShader(GL_VERTEX_SHADER, vertexShaderString);
    _fragmentShader = InitShader(GL_FRAGMENT_SHADER, fragmentShaderString);
    
    _program = glCreateProgram();
    glAttachShader(_program, _vertexShader);
    glAttachShader(_program, _fragmentShader);
    glLinkProgram(_program);
    
    if (ValidateProgram(_program))
    {
        glBindFragDataLocation(_program, 0, "o_frag_color");
        _u_color_location = glGetUniformLocation(_program, "u_color");
        _u_alpha_location = glGetUniformLocation(_program, "u_alpha");
    }
    
    _initialized = YES;
}

- (void)use
{
    if (!_initialized) [self setup];
    
    glUseProgram(_program);
    glUniform1i(_u_color_location, 0);
    glUniform1f(_u_alpha_location, _discardAlpha ? 1 : 0);
}

@end
