/*
 *  Copyright (c) 2009-2021 Erik Doernenburg and contributors
 *
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License. You may obtain
 *  a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 *  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 *  License for the specific language governing permissions and limitations
 *  under the License.
 */

#import <objc/runtime.h>
#import "OCMArg.h"
#import "OCMBlockArgCaller.h"
#import "OCMConstraint.h"
#import "OCMPassByRefSetter.h"


@implementation OCMArg

+ (id)any
{
    return [[[OCMAnyConstraint alloc] init] autorelease];
}

+ (void *)anyPointer
{
    return (void *)0x01234567;
}

+ (id __autoreleasing *)anyObjectRef
{
    return (id *)0x01234567;
}

+ (SEL)anySelector
{
    return NSSelectorFromString(@"aSelectorThatMatchesAnySelector");
}

+ (id)isNil
{
    return [[OCMIsNilConstraint alloc] init];
}

+ (id)isNotNil
{
    return [[OCMIsNotNilConstraint alloc] init];
}

+ (id)isEqual:(id)value
{
	return [[[OCMIsEqualConstraint alloc] initWithTestValue:value] autorelease];
}

+ (id)isNotEqual:(id)value
{
    return [[[OCMIsNotEqualConstraint alloc] initWithTestValue:value] autorelease];
}

+ (id)isKindOfClass:(Class)cls
{
    return [[[OCMBlockConstraint alloc] initWithConstraintBlock:^BOOL(id obj) {
        return [obj isKindOfClass:cls];
    }] autorelease];
}

+ (id)checkWithSelector:(SEL)selector onObject:(id)anObject
{
    return [OCMConstraint constraintWithSelector:selector onObject:anObject];
}

+ (id)checkWithBlock:(BOOL (^)(id))block
{
    return [[[OCMBlockConstraint alloc] initWithConstraintBlock:block] autorelease];
}

+ (id *)setTo:(id)value
{
    return (id *)[[[OCMPassByRefSetter alloc] initWithValue:value] autorelease];
}

+ (void *)setToValue:(NSValue *)value
{
    return (id *)[[[OCMPassByRefSetter alloc] initWithValue:value] autorelease];
}

+ (id)invokeBlock
{
    return [[[OCMBlockArgCaller alloc] init] autorelease];
}

+ (id)invokeBlockWithArgs:(id)first, ... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray *params = [NSMutableArray array];
    va_list args;
    if(first)
    {
        [params addObject:first];
        va_start(args, first);
        id obj;
        while((obj = va_arg(args, id)))
        {
            [params addObject:obj];
        }
        va_end(args);
    }
    return [[[OCMBlockArgCaller alloc] initWithBlockArguments:params] autorelease];
}

+ (id)defaultValue
{
    return [NSNull null];
}


+ (id)resolveSpecialValues:(NSValue *)value
{
    const char *type = [value objCType];
    if(type[0] == '^')
    {
        void *pointer = [value pointerValue];
        if(pointer == (void *)0x01234567)
            return [OCMArg any];
        if((pointer != NULL) && (object_getClass((id)pointer) == [OCMPassByRefSetter class]))
            return (id)pointer;
    }
    else if(type[0] == ':')
    {
        SEL selector;
        [value getValue:&selector];
        if(selector == NSSelectorFromString(@"aSelectorThatMatchesAnySelector"))
            return [OCMArg any];
    }
    return value;
}

@end
