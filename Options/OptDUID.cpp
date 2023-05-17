/*
 * Dibbler - a portable DHCPv6
 *
 * authors: Tomasz Mrugalski <thomson@klub.com.pl>
 *          Marek Senderski <msend@o2.pl>
 *
 * released under GNU GPL v2 licence
 *
 */

#include <stdlib.h>
#include "Portable.h"
#include "DHCPConst.h"
#include "OptDUID.h"

TOptDUID::TOptDUID(int type, SPtr<TDUID> duid, TMsg* parent)
    :TOpt(type, parent)
{
    DUID=duid;
}

TOptDUID::TOptDUID(const TOptDUID& copy)
    :TOpt(copy.OptType, NULL)
{
    this->DUID = copy.DUID;
}

size_t TOptDUID::getSize() {
    if (DUID)
	return DUID->getLen() + 4;
    return 4;
}

char * TOptDUID::storeSelf( char* buf)
{
    buf = writeUint16(buf, OptType);
    buf = writeUint16(buf, DUID->getLen());
    return this->DUID->storeSelf(buf);
}

TOptDUID::TOptDUID(int type, const char* buf, int bufsize, TMsg* parent)
    :TOpt(type, parent)
{
    this->DUID = new TDUID(buf,bufsize);
}

SPtr<TDUID> TOptDUID::getDUID() const
{
    return DUID;
}

bool TOptDUID::isValid() const
{
    if (this->getDUID()->getLen()>2) 
        return true;
    return false;
}

std::string TOptDUID::getPlain() {
    if (DUID) {
        return DUID->getPlain();
    } else {
        return std::string("");
    }
}

std::ostream & operator<<(std::ostream & out, TOptDUID &x)
{
    out << "    <option 1>" << x.getPlain() << "</option>" << std::endl;
    return out;
}
