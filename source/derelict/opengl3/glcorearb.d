/*

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

*/
module derelict.opengl3.glcorearb;


public {
    import derelict.opengl3.internal.globalctx;
}

private {
    import std.algorithm;
    import std.conv;

    import derelict.util.loader;
    import derelict.util.exception;
    import derelict.util.system;
    import derelict.opengl3.internal.common;
    import derelict.opengl3.internal.coreload;
    import derelict.opengl3.internal.platform;

    static if( Derelict_OS_Windows ) {
        enum libNames = "opengl32.dll";
    } else static if( Derelict_OS_Mac ) {
        enum libNames = "../Frameworks/OpenGL.framework/OpenGL, /Library/Frameworks/OpenGL.framework/OpenGL, /System/Library/Frameworks/OpenGL.framework/OpenGL";
    } else static if( Derelict_OS_Posix ) {
        enum libNames = "libGL.so.1,libGL.so";
    } else
        static assert( 0, "Need to implement OpenGL libNames for this operating system." );
}

class DerelictGL3Loader : SharedLibLoader {
    alias ctx = derelict.opengl3.internal.globalctx;

    private GLVersion _loadedVersion;

    public {
        this() {
            super( libNames );
        }

        GLVersion loadedVersion() @property {
            return _loadedVersion;
        }

        GLVersion reload() {
            // Make sure a context is active, otherwise this could be meaningless.
            if( !hasValidContext!ctx() )
                throw new DerelictException( "DerelictGL3.reload failure: An OpenGL context is not currently active." );

            GLVersion glVer = GLVersion.GL11;
            scope( exit ) _loadedVersion = glVer;

            GLVersion maxVer = findMaxAvailableVersion!ctx();
            glVer = loadContext!ctx( maxVer );

            loadPlatformEXT!ctx(  glVer  );

            return glVer;
        }
    }

    protected override void loadSymbols() {
        loadBase!ctx( &bindFunc );
        _loadedVersion = GLVersion.GL11;

        loadPlatformGL!ctx( &bindFunc );
    }
}

__gshared DerelictGL3Loader DerelictGL3;

shared static this() {
    DerelictGL3 = new DerelictGL3Loader;
}
